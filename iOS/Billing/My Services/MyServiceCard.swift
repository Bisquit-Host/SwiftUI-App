import ScrechKit
import BisquitoNet

struct MyServiceCard: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(DashboardViewVM.self) private var dashboardVM
    
    private let service: BillingMyService
    
    init(_ service: BillingMyService) {
        self.service = service
    }
    
    @State private var alertRename = false
    @State private var newName = ""
    @State private var isRenaming = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if differentiateWithoutColor {
                    Text(state.title.lowercased().capitalized)
                }
                
                HStack {
                    if !differentiateWithoutColor {
                        PulseCircle(state.color)
                    }
                    
                    Text(name)
                        .subheadline(.semibold)
                }
                
                HStack(spacing: 6) {
                    MyServiceFlagImage(flagUrl)
                    
                    Text(location)
                        .footnote()
                        .secondary()
                    
                    if let system {
                        Text("• \(system)")
                            .footnote()
                            .secondary()
                    }
                }
                
                if let ip {
                    Label(ip, systemImage: "network")
                        .footnote()
                        .secondary()
                }
            }
            
            Spacer()
            
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(priceText)
                    .footnote()
                    .foregroundStyle(.primary)
                
                Text("/mo")
                    .secondary()
                    .caption2()
            }
        }
        .padding(.vertical, 6)
        .contextMenu {
            Button("Rename", systemImage: "pencil") {
                newName = name
                alertRename = true
            }
        }
        .alert("Rename service", isPresented: $alertRename) {
            TextField("New name", text: $newName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            Button("Save", role: .confirmy, action: save)
                .disabled(isRenaming)
            
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func save() {
        Task {
            await rename(to: newName)
            newName = ""
        }
    }
    
    private var name: String {
        switch service {
        case .cloud(let service): service.name
        case .game(let service): service.name
        case .bot(let service): service.name
        }
    }
    
    private var state: BillingServiceState {
        switch service {
        case .cloud(let service): service.state
        case .game(let service): service.state
        case .bot(let service): service.state
        }
    }
    
    private var flagUrl: String? {
        switch service {
        case .cloud(let service): service.locationFlagUrl
        case .game(let service): service.locationFlagUrl
        case .bot(let service): service.locationFlagUrl
        }
    }
    
    private var location: String {
        switch service {
        case .cloud(let service): service.locationName
        case .game(let service): service.locationName
        case .bot(let service): service.locationName
        }
    }
    
    private var system: String? {
        switch service {
        case .cloud(let service): service.system
        default: nil
        }
    }
    
    private var ip: String? {
        switch service {
        case .cloud(let service): service.ip
        default: nil
        }
    }
    
    private var priceText: String {
        let amount: Int64 = switch service {
        case .cloud(let service): service.price
        case .game(let service): service.price
        case .bot(let service): service.price
        }
        
        if let currency = dashboardVM.user?.currency {
            return formatCurrencyValue(
                amount,
                currency: currency,
                minimumFractionDigits: 0,
                maximumFractionDigits: currency.fractionDigits
            )
        }
        
        return formatCurrency(amount, user: nil)
    }
    
    private func rename(to pendingName: String) async {
        let trimmed = pendingName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            SystemAlert.error("Enter a name")
            return
        }
        
        guard trimmed != name else { return }
        guard !isRenaming else { return }
        guard let accessToken = accessToken() else { return }
        
        isRenaming = true
        defer { isRenaming = false }
        
        let didRename: Bool = switch service {
        case .cloud:
            await cloudServiceRenameAPI(
                newName: trimmed,
                serviceId: service.id,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil
            
        case .game:
            await gameServiceRenameAPI(
                newName: trimmed,
                serviceId: service.id,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil
            
        case .bot:
            await botServiceRenameAPI(
                newName: trimmed,
                serviceId: service.id,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil
        }
        
        guard didRename else { return }
        
        SystemAlert.copied("Name updated")
        NotificationCenter.default.post(name: .billingMyServicesShouldRefresh, object: nil)
    }
}

extension Notification.Name {
    static let billingMyServicesShouldRefresh = Notification.Name("billingMyServicesShouldRefresh")
}
