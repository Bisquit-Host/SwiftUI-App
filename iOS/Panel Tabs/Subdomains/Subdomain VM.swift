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
    
    func deleteSubdomain(_ subdomainId: Int) async {
        guard
            let url = URL(string: "https://mgr.bisquit.host/api/client/extensions/subdomainmanager/servers/" + id + "/\(subdomainId)"),
            let apiKey = Keychain.load(key: "selectedApiKey")
        else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.httpShouldHandleCookies = false
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let _ = try await URLSession.shared.data(for: request)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func syncSubdomain(_ subdomainId: Int) async {
        guard
            let url = URL(string: "https://mgr.bisquit.host/api/client/extensions/subdomainmanager/servers/" + id + "/" + String(subdomainId) + "/sync"),
            let apiKey = Keychain.load(key: "selectedApiKey")
        else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpShouldHandleCookies = false
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let _ = try await URLSession.shared.data(for: request)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createSubdomain(onSuccess: @escaping () -> Void) async {
        guard
            let url = URL(string: "https://mgr.bisquit.host/api/client/extensions/subdomainmanager/servers/" + id),
            let apiKey = Keychain.load(key: "selectedApiKey")
        else {
            return
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpShouldHandleCookies = false
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Append subdomain
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"subdomain\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(subdomain)\r\n".data(using: .utf8)!)
        
        // Append domain
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"domain\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(selectedDomain)\r\n".data(using: .utf8)!)
        
        // Final boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let _ = try decoder.decode(Subdomain.self, from: data)
            
            await fetchSubdomains()
            onSuccess()
        } catch {
            print("Error:", error)
        }
    }
    
    func fetchSubdomains() async {
        guard
            let url = URL(string: "https://mgr.bisquit.host/api/client/extensions/subdomainmanager/servers/" + id),
            let apiKey = Keychain.load(key: "selectedApiKey")
        else {
            return
        }
        
        var request = URLRequest(url: url)
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
