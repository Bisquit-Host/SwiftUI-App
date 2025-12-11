import Foundation
import PteroNet

@Observable
final class BillingDashboardVM {
    var user: BillingUser? = nil
    
    func refreshAuthToken(onSuccess: @escaping () async -> Void = {}) async {
        guard let url = URL(string: "https://test-api.bisquit.host/auth/refresh") else { return }
        
        guard let refreshToken = Keychain.load(key: "refresh_token") else {
            print("Rrror: refresh token not found", #function)
            return
        }
        
        guard !refreshToken.isEmpty else { return }
        
        let body = ["refreshToken": refreshToken]
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            
            if let httpResponse = response as? HTTPURLResponse {
                let status = httpResponse.statusCode
                
                print("Refresh token status code:", status)
            }
            
            if let bodyString = String(data: data, encoding: .utf8) {
                print("Body:", bodyString)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let refreshedCreds = try decoder.decode(BillingLoginResponse.self, from: data)
            
            Keychain.save(refreshedCreds.accessToken, forKey: "access_token")
            Keychain.save(refreshedCreds.refreshToken, forKey: "refresh_token")
            ValueStore().lastBillingTokenRefresh = Date()
            ValueStore().testExpiresIn = refreshedCreds.expiresIn
            
            await onSuccess()
        } catch {
            print("Error refreshing access_token:", error.localizedDescription)
            return
        }
    }
    
    func fetchUserInfo() async {
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            return
        }
        
        let path = "https://test-api.bisquit.host/user"
        
        guard let url = URL(string: path) else { return }
        
        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            
            if let httpResponse = response as? HTTPURLResponse {
                let status = httpResponse.statusCode
                
                print("User info status code:", status)
                
                if status == 401 {
                    let _ = await refreshAuthToken()
                }
            }
            
            if let bodyString = String(data: data, encoding: .utf8) {
                print("Body:", bodyString)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            
            user = try decoder.decode(BillingUser.self, from: data)
        } catch {
            print("Error fetching user data:", error)
        }
    }
}
