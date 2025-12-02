import Foundation

@Observable
final class BillingCloudServicesVM {
    var services: [BillingCloudServiceSummary] = []
    var isLoading = false
    var lastError: String?
    
    func loadServices() async {
        guard !isLoading else { return }
        isLoading = true
        lastError = nil
        
        defer { isLoading = false }
        
        guard let url = URL(string: "https://test-api.bisquit.host/cloud") else {
            lastError = "Invalid URL"
            return
        }
        
        let token = ValueStore().testAccessToken
        if token.isEmpty {
            lastError = "Missing session"
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                lastError = "No response"
                print("Cloud services: missing HTTPURLResponse")
                return
            }
            
            guard http.statusCode == 200 else {
                lastError = String(data: data, encoding: .utf8) ?? "Status \(http.statusCode)"
                print("Cloud services error \(http.statusCode):", lastError ?? "")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            services = try decoder.decode([BillingCloudServiceSummary].self, from: data)
        } catch {
            lastError = error.localizedDescription
            print("Cloud services load failed:", error)
        }
    }
}
