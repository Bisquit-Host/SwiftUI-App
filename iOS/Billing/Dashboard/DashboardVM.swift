import Foundation
import BisquitoNet
import PteroNet

@Observable
final class DashboardVM {
    var user: BillingUser? = nil
    
    func fetchUserInfo(onUnauthorized: @MainActor @escaping () async -> Void = {}) async {
        guard let accessToken = accessToken() else { return }
        
        user = await fetchUserInfoAPI(
            accessToken: accessToken,
            onUnauthorized: onUnauthorized,
            onBillingError: SystemAlert.error
        )
    }
}
