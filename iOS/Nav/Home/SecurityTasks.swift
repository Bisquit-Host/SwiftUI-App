import Foundation
import Calagopus
import AutoUpdate

@Observable
final class SecurityTasks {
    var alertUpdate = false
    var alertTwoFA = false
    
    private let logger = Logger(subsystem: "host.bisquit.Bisquit-host", category: "SecurityTasks")
    
    func startCheck() async {
        try? await Task.sleep(for: .seconds(1))
        
        async let updates: () = await checkForUpdates()
        async let twoFA: () = await checkForTwoFA()
        
        let _ = await (updates, twoFA)
    }
    
    private func checkForUpdates() async {
#if os(macOS)
        return
#else
        let updateChecker = AppStoreUpdateChecker(appID: 1639409934)
        
        guard let status = await updateChecker.checkForUpdates() else {
            alertUpdate = false
            logger.error("Error checking for updates")
            return
        }
        
        alertUpdate = status.updateAvailable
        
        if status.updateAvailable {
            logger.info("🛡️ Update available: \(status.currentVersion) -> \(status.appStoreVersion ?? "unknown")")
        } else {
            logger.info("🛡️ The app is up to date")
        }
#endif
    }
    
    private func checkForTwoFA() async {
        do {
            let _ = try await CalagopusNet.client().twoFactorDetails()
            alertTwoFA = true
            logger.info("🛡️ 2FA disabled")
            
        } catch CalagopusTwoFactorError.alreadyEnabled {
            alertTwoFA = false
            logger.info("🛡️ 2FA enabled")
            
        } catch {
            logger.error("Error checking 2FA status: \(error)")
            alertTwoFA = false
        }
    }
}
