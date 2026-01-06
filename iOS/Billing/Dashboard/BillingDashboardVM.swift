import Foundation
import BisquitoNet
import PteroNet

@Observable
final class BillingDashboardVM {
    var user: BillingUser? = nil
    
    func refreshAuthToken(onSuccess: @escaping () async -> Void = {}) async {
        guard let url = URL(string: "\(Endpoint.basePath)auth/refresh") else { return }
        
        guard let refreshToken = Keychain.load(key: "refresh_token") else {
            SystemAlert.error("Error: refresh token not found", subtitle: #function)
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
                Logger().info("\(status) Refresh token")
            }
            
            prettyJSON(data)
            
            let refreshedCreds = try BigAssDecoder.decode(BillingLoginResponse.self, from: data)
            
            Keychain.save(refreshedCreds.accessToken, forKey: "access_token")
            Keychain.save(refreshedCreds.refreshToken, forKey: "refresh_token")
            
            ValueStore().lastBillingTokenRefresh = Date()
            ValueStore().accessTokenExpiresIn = refreshedCreds.expiresIn
            
            await onSuccess()
        } catch {
            SystemAlert.error("Error refreshing access token", subtitle: error.localizedDescription)
            return
        }
    }
    
    func fetchUserInfo() async {
        guard let accessToken = Keychain.load(key: "access_token") else {
            SystemAlert.error("Access token not found", subtitle: #function)
            return
        }
        
        guard let url = URL(string: "\(Endpoint.basePath)user") else { return }
        
        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            prettyJSON(data)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    let _ = await refreshAuthToken()
                }
            }
            
            user = try BigAssDecoder.decode(BillingUser.self, from: data)
        } catch {
            Logger().error("Error fetching user data: \(error)")
        }
    }
}
