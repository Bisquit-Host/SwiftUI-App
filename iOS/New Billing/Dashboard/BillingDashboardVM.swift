import Foundation

@Observable
final class BillingDashboardVM {
    var user: BillingUser? = nil
    
    func fetchUserInfo() async {
        let path = "https://test-api.bisquit.host/user"
        
        guard let url = URL(string: path) else { return }
        
        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            user = try decoder.decode(BillingUser.self, from: data)
        } catch {
            print("Error fetching user data:", error.localizedDescription)
        }
    }
}
