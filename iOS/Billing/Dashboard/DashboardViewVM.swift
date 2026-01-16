import Foundation
import BisquitoNet
import PteroNet

@Observable
final class DashboardViewVM {
    var user: BillingUser? = nil
    
    func refreshAuthToken(onSuccess: @escaping () async -> Void = {}) async {
        guard let refreshToken = Keychain.load(key: "refresh_token"), !refreshToken.isEmpty else {
            SystemAlert.error("Refresh token not found", subtitle: #function)
            return
        }
        
        guard let credentials = await refreshAuthTokenAPI(refreshToken: refreshToken, onBillingError: SystemAlert.error) else {
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
        guard let accessToken = accessToken() else { return }
        let result = await fetchUserInfoAPI(accessToken: accessToken)
        
        if result.statusCode == 401 {
            let _ = await refreshAuthToken()
        }
        
        guard let data = result.data else { return }
        
        do {
            user = try BigAssDecoder.decode(BillingUser.self, from: data)
        } catch {
            Logger().error("Error fetching user data: \(error)")
        }
    }
}
