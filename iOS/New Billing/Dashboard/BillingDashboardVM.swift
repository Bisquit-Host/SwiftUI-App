import Foundation

@Observable
final class BillingDashboardVM {
    var user: BillingUser? = nil
    
    func refreshAuth(onSuccess: @escaping () async -> Void) async {
        let path = "https://test-api.bisquit.host/auth/refresh"
        
        guard let url = URL(string: path) else { return }
        
        let store = ValueStore()
        let body = ["refreshToken": store.testRefreshToken]
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            
            if let httpResponse = response as? HTTPURLResponse {
                let status = httpResponse.statusCode
                
                print("Status code:", status)
            }
            
            if let bodyString = String(data: data, encoding: .utf8) {
                print("Body:", bodyString)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let refreshedCreds = try decoder.decode(BillingLoginResponse.self, from: data)
            
            ValueStore().testAccessToken = refreshedCreds.accessToken
            ValueStore().testRefreshToken = refreshedCreds.refreshToken
            ValueStore().testExpiresIn = refreshedCreds.expiresIn
            
            await onSuccess()
        } catch {
            print("Error refreshing access_token:", error.localizedDescription)
            return
        }
    }
    
    func fetchUserInfo() async {
        let path = "https://test-api.bisquit.host/user"
        let store = ValueStore()
        
        guard let url = URL(string: path) else { return }
        
        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(store.testAccessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            
            if let httpResponse = response as? HTTPURLResponse {
                let status = httpResponse.statusCode
                
                print("Status code:", status)
                
                if status == 401 {
                    let _ = await refreshAuth {
                        await self.fetchUserInfo()
                    }
                }
            }
            
            if let bodyString = String(data: data, encoding: .utf8) {
                print("Body:", bodyString)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            user = try decoder.decode(BillingUser.self, from: data)
        } catch {
            print("Error fetching user data:", error)
        }
    }
}
