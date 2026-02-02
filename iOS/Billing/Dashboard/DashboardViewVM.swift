import Foundation
import BisquitoNet
import PteroNet

@Observable
final class DashboardViewVM {
    var user: BillingUser? = nil
    private var refreshTask: Task<Void, Never>? = nil
    
    func refreshAuthToken() async {
        if let refreshTask {
            await refreshTask.value
            return
        }
        
        let task = Task { @MainActor [weak self] in
            guard let self else { return }
            await self.performRefreshAuthToken()
        }
        
        refreshTask = task
        defer { refreshTask = nil }
        await task.value
    }
    
    private func performRefreshAuthToken() async {
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
        
        Logger().info("Refreshed auth token")
    }
    
    func fetchUserInfo() async {
        guard let accessToken = accessToken() else { return }
        
        user = await fetchUserInfoAPI(
            accessToken: accessToken,
            onUnauthorized: { [weak self] in
                let _ = await self?.refreshAuthToken()
            },
            onBillingError: SystemAlert.error
        )
    }
}
