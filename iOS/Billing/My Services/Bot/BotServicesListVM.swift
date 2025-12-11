import Foundation
import PteroNet

@Observable
final class BotServicesListVM {
    var services: [BillingBotServiceSummary] = []
    var isLoading = false
    
    func loadServices() async {
        await fetch(path: "https://test-api.bisquit.host/bot")
    }
    
    private func fetch(path: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: path) else {
            SystemAlert.error("Invalid URL")
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
                return
            }
            
            guard http.statusCode == 200 else {
                let error = String(data: data, encoding: .utf8) ?? "Status \(http.statusCode)"
                
                SystemAlert.error(error)
                print("Bot services error \(http.statusCode):", error)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            services = try decoder.decode([BillingBotServiceSummary].self, from: data)
        } catch {
            SystemAlert.error(error.localizedDescription)
            print("Bot services load failed:", error)
        }
    }
}
