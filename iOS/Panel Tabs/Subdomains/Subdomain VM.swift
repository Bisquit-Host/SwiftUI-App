import PteroNet

@Observable
final class SubdomainVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var subdomain = ""
    var selectedDomain = 1
    
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
        let url = URL(string: "https://mgr.bisquit.host/api/client/extensions/subdomainmanager/servers/" + id)
        
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

// https://mgr.bisquit.host/api/client/extensions/subdomainmanager/servers/4e400cc0-ef40-4247-a375-676acaaa83a2
//{ response
//    "object": "server_subdomain",
//    "attributes": {
//        "id": 43,
//        "subdomain": "test",
//        "domain": "goida.host",
//        "created_at": "2025-02-05 16:47:30"
//    }
//}
// body: {"subdomain":"test","domain":1}
