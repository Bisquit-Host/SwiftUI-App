import Foundation

@Observable
final class SheetTopupVM {
    var operations: [BillingOperation] = []
    var isLoading = false
    
    private let baseURL = "https://test-api.bisquit.host"
    
    func fetchOperations(accessToken: String) async {
        guard !accessToken.isEmpty else {
            print("Missing access token")
            return
        }
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        guard let url = URL(string: "\(baseURL)/finances/operations") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse {
                print("Billing operations status:", http.statusCode)
                
                if http.statusCode == 401 {
                    SystemAlert.error("Unauthorized", subtitle: "401")
                    return
                }
                
                if http.statusCode == 204 {
                    operations = []
                    return
                }
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: pretty, encoding: .utf8) {
                print("Operations response:\\n\(prettyString)")
                
            } else if let raw = String(data: data, encoding: .utf8) {
                print("Operations raw response:\\n\(raw)")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            operations = try decoder.decode(BillingOperationsResponse.self, from: data).operations
        } catch {
            print("❌ Failed to fetch operations:", error.localizedDescription)
            SystemAlert.error("Error", subtitle: error.localizedDescription)
        }
    }
}
