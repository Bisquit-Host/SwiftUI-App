import Foundation
import BisquitoNet
import PteroNet

@Observable
final class BillingDashboardVM {
    var user: BillingUser? = nil
    
    func refreshAuthToken(onSuccess: @escaping () async -> Void = {}) async {
        guard let refreshToken = Keychain.load(key: "refresh_token"), !refreshToken.isEmpty else {
            SystemAlert.error("Refresh token not found", subtitle: #function)
            return
        }
        
        guard let credentials = await refreshAuthTokenAPI(refreshToken: refreshToken) else {
            SystemAlert.error("Error refreshing access token")
            return
        }
        
        Keychain.save(credentials.accessToken, forKey: "access_token")
        Keychain.save(credentials.refreshToken, forKey: "refresh_token")
        
        ValueStore().lastBillingTokenRefresh = Date()
        ValueStore().accessTokenExpiresIn = credentials.expiresIn
        
        await onSuccess()
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
            let (data, res) = try await URLSession.shared.data(for: req)
            prettyJSON(data)
            
            if let httpResponse = res as? HTTPURLResponse {
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
