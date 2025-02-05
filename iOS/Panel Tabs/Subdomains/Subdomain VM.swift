import PteroNet

@Observable
final class SubdomainVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private var subdomainResponse: SubdomainResponse?
    
    var limit: Int? {
        subdomainResponse?.limit
    }
    
    var domains: [Domain]? {
        subdomainResponse?.domains
    }
    
    var subdomains: [SubdomainAttributes] {
        subdomainResponse?.subdomains.map(\.attributes) ?? []
    }
    
    func fetchSubdomains() async {
        let url = URL(string: "https://mgr.bisquit.host/api/client/extensions/subdomainmanager/servers/\(id)")
        
        guard let apiKey = Keychain.load(key: "selectedApiKey") else {
            return
        }
        
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let response = try decoder.decode(SubdomainResponse.self, from: data)
            
            await MainActor.run {
                self.subdomainResponse = response
            }
        } catch {
            print("Error:", error)
        }
    }
}
