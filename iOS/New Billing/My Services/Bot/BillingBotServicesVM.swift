import Foundation

@Observable
final class BillingBotServicesVM {
    var services: [BillingBotServiceSummary] = []
    var isLoading = false
    var lastError: String?
    
    func loadServices() async {
        await fetch(path: "https://test-api.bisquit.host/bot")
    }
    
    private func fetch(path: String) async {
        guard !isLoading else { return }
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        guard let url = URL(string: path) else {
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
                return
            }
            
            guard http.statusCode == 200 else {
                lastError = String(data: data, encoding: .utf8) ?? "Status \(http.statusCode)"
                print("Bot services error \(http.statusCode):", lastError ?? "")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            services = try decoder.decode([BillingBotServiceSummary].self, from: data)
        } catch {
            lastError = error.localizedDescription
            print("Bot services load failed:", error)
        }
    }
}
