import Foundation
import PteroNet

@Observable
final class VDSBillingVM {
    var services: [CloudServiceSummary] = []
    var isLoading = false
    
    func loadServices() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: "\(Endpoint.basePath)cloud") else {
            print("Invalid URL")
            return
        }
        
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                SystemAlert.error("No response")
                print("Cloud services: missing HTTPURLResponse")
                return
            }
            
            guard http.statusCode == 200 else {
                let error = String(data: data, encoding: .utf8) ?? "Status \(http.statusCode)"
                SystemAlert.error(error)
                print("Cloud services error \(http.statusCode):", error)
                return
            }
            
            services = try BigAssDecoder.decode([CloudServiceSummary].self, from: data)
        } catch {
            SystemAlert.error(error.localizedDescription)
            print("Cloud services load failed:", error)
        }
    }
}
