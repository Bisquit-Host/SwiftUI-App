import ScrechKit
import BisquitoNet
import PteroNet

struct MyServiceCard: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
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
            
            Button("Save", role: .confirm, action: save)
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
    
    private var priceText: Double {
        switch service {
        case .cloud(let service): service.price
        case .game(let service): service.price
        case .bot(let service): service.price
        }
    }
    
    private func rename(to pendingName: String) async {
        let trimmed = pendingName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            SystemAlert.error("Enter a name")
            return
        }
        
        guard trimmed != name else { return }
        guard !isRenaming else { return }
        
        isRenaming = true
        defer { isRenaming = false }
        
        let renamePath: String = switch service {
        case .cloud: "/cloud/\(service.id)/name"
        case .game: "/game/\(service.id)/name"
        case .bot: "/bot/\(service.id)/name"
        }
        
        let body = ["name": trimmed]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        guard await request(path: renamePath, method: "PATCH", body: payload) != nil else { return }
        
        SystemAlert.copied("Name updated")
        NotificationCenter.default.post(name: .billingMyServicesShouldRefresh, object: nil)
    }
    
    private func request(path: String, method: String, body: Data) async -> Data? {
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            return nil
        }
        
        guard let base = URL(string: "https://test-api.bisquit.host") else { return nil }
        guard let url = URL(string: path, relativeTo: base) else {
            SystemAlert.error("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            
            guard let http = res as? HTTPURLResponse else {
                SystemAlert.error("No response")
                return nil
            }
            
            if http.statusCode == 204 {
                return Data()
            }
            
            if decodeBillingError(data, with: res, onDecode: SystemAlert.error) {
                return nil
            }
            
            return data
        } catch {
            SystemAlert.error(error.localizedDescription)
            return nil
        }
    }
}

extension Notification.Name {
    static let billingMyServicesShouldRefresh = Notification.Name("billingMyServicesShouldRefresh")
}
