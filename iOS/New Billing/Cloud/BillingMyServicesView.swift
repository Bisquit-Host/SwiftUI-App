import SwiftUI

struct BillingMyServicesView: View {
    @State private var cloudVM = BillingCloudServicesVM()
    @State private var gameVM = BillingGameServicesVM()
    @State private var botVM = BillingBotServicesVM()
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    var body: some View {
        List {
            section("VDS", services: cloudVM.services.map { .cloud($0) }, isLoading: cloudVM.isLoading, error: cloudVM.lastError) {
                BillingCloudServiceDetailView(serviceId: $0)
                    .environment(dashboardVM)
            }
            
            section("Game servers", services: gameVM.services.map { .game($0) }, isLoading: gameVM.isLoading, error: gameVM.lastError) { id in
                BillingGameServiceDetailView(serviceId: id)
                    .environment(dashboardVM)
            }
            
            section("Bot hosting", services: botVM.services.map { .bot($0) }, isLoading: botVM.isLoading, error: botVM.lastError) { id in
                BillingBotServiceDetailView(serviceId: id)
                    .environment(dashboardVM)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("My services")
        .refreshableTask {
            await cloudVM.loadServices()
            await gameVM.loadServices()
            await botVM.loadServices()
        }
    }
    
    // MARK: - Sections
    
    @ViewBuilder
    private func section(_ title: String, services: [BillingAnyService], isLoading: Bool, error: String?, detail: @escaping (Int) -> some View) -> some View {
        Section(title) {
            if isLoading && services.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if let error {
                Text(error)
                    .foregroundStyle(.red)
                    .footnote()
            }
            
            if services.isEmpty && !isLoading {
                Text("No services yet")
                    .secondary()
                    .footnote()
            } else {
                ForEach(services) { item in
                    NavigationLink {
                        detail(item.id)
                    } label: {
                        BillingServiceRow(item)
                    }
                }
            }
        }
    }
}

private enum BillingAnyService: Identifiable {
    case cloud(BillingCloudServiceSummary),
         game(BillingGameServiceSummary),
         bot(BillingBotServiceSummary)
    
    var id: Int {
        switch self {
        case .cloud(let s): s.id
        case .game(let s): s.id
        case .bot(let s): s.id
        }
    }
}

private struct BillingServiceRow: View {
    private let service: BillingAnyService
    
    init(_ service: BillingAnyService) {
        self.service = service
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .subheadline(.semibold)
                
                Spacer()
                
                Label(state.title, systemImage: "circle.fill")
                    .labelStyle(.titleAndIcon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(state.color)
            }
            
            HStack(spacing: 6) {
                if let flag = flagUrl, let url = URL(string: flag) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: 20, height: 14)
                                .clipShape(.rect(cornerRadius: 2))
                        default:
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.gray.opacity(0.2))
                                .frame(width: 20, height: 14)
                        }
                    }
                }
                
                Text(location)
                    .footnote()
                    .secondary()
                
                if let system {
                    Text("• \(system)")
                        .footnote()
                        .secondary()
                }
            }
            
            HStack {
                if let ip {
                    Label(ip, systemImage: "network")
                        .footnote()
                        .secondary()
                }
                
                Spacer()
                
                Text(priceText)
                    .footnote()
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 6)
    }
    
    private var name: String {
        switch service {
        case .cloud(let s): s.name
        case .game(let s): s.name
        case .bot(let s): s.name
        }
    }
    
    private var state: BillingServiceState {
        switch service {
        case .cloud(let s): s.state
        case .game(let s): s.state
        case .bot(let s): s.state
        }
    }
    
    private var flagUrl: String? {
        switch service {
        case .cloud(let s): s.locationFlagUrl
        case .game(let s): s.locationFlagUrl
        case .bot(let s): s.locationFlagUrl
        }
    }
    
    private var location: String {
        switch service {
        case .cloud(let s): s.locationName
        case .game(let s): s.locationName
        case .bot(let s): s.locationName
        }
    }
    
    private var system: String? {
        switch service {
        case .cloud(let s): s.system
        default: nil
        }
    }
    
    private var ip: String? {
        switch service {
        case .cloud(let s): s.ip
        default: nil
        }
    }
    
    private var priceText: String {
        let price: Double
        switch service {
        case .cloud(let s): price = s.price
        case .game(let s): price = s.price
        case .bot(let s): price = s.price
        }
        return "\(Int(price))₽/mo"
    }
}

#Preview {
    NavigationStack {
        BillingMyServicesView()
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
