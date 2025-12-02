import SwiftUI

struct BillingCloudServicesList: View {
    @State private var vm = BillingCloudServicesVM()
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    var body: some View {
        List {
            if vm.isLoading && vm.services.isEmpty {
                Section {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            if let error = vm.lastError {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .footnote()
                }
            }
            
            Section("VDS") {
                if vm.services.isEmpty && !vm.isLoading {
                    Text("No services yet")
                        .secondary()
                        .footnote()
                } else {
                    ForEach(vm.services) { service in
                        NavigationLink {
                            BillingCloudServiceDetailView(serviceId: service.id)
                                .environment(dashboardVM)
                        } label: {
                            BillingCloudServiceRow(service)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("My services")
        .refreshable {
            await vm.loadServices()
        }
        .task {
            await vm.loadServices()
        }
    }
}

private struct BillingCloudServiceRow: View {
    let service: BillingCloudServiceSummary
    
    init(_ service: BillingCloudServiceSummary) {
        self.service = service
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(service.name)
                    .subheadline(.semibold)
                
                Spacer()
                
                Label(service.state.title, systemImage: "circle.fill")
                    .labelStyle(.titleAndIcon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(service.state.color)
            }
            
            HStack(spacing: 6) {
                if let urlString = service.locationFlagUrl, let url = URL(string: urlString) {
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
                
                Text(service.locationName)
                    .footnote()
                    .secondary()
                
                if let system = service.system {
                    Text("• \(system)")
                        .footnote()
                        .secondary()
                }
            }
            
            HStack {
                if let ip = service.ip {
                    Label(ip, systemImage: "network")
                        .footnote()
                        .secondary()
                }
                
                Spacer()
                
                Text("\(Int(service.price))₽/mo")
                    .footnote()
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        BillingCloudServicesList()
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
