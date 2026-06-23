import Foundation
import Calagopus
import AutoUpdate

@Observable
final class SecurityTasks {
    var alertUpdate = false
    var alertUnusedAPIKeys = false
    var alertTwoFA = false
    
    private let logger = Logger(subsystem: "host.bisquit.Bisquit-host", category: "SecurityTasks")
    
    func startCheck() async {
        try? await Task.sleep(for: .seconds(1))
        
        async let updates: () = await checkForUpdates()
        async let keys: () = await checkForUnusedAPIKeys()
        async let twoFA: () = await checkForTwoFA()
        
        let _ = await (updates, keys, twoFA)
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
            guard let apiKey = Keychain.load(key: "selectedApiKey"), !apiKey.isEmpty else {
                alertTwoFA = false
                return
            }
            
            let _ = try await CalagopusClient(apiKey: apiKey).twoFactorDetails()
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
    
    private func checkForUnusedAPIKeys() async {
        do {
            guard let apiKey = Keychain.load(key: "selectedApiKey"), !apiKey.isEmpty else {
                alertUnusedAPIKeys = false
                return
            }
            
            let apiKeys = try await CalagopusClient(apiKey: apiKey).apiKeys().data
            
            guard let after2Months = Calendar.current.date(byAdding: .month, value: -2, to: Date()) else {
                return
            }
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime]
            
            alertUnusedAPIKeys = apiKeys.contains { key in
                let dateString = key.lastUsedAt ?? key.createdAt
                
                guard let date = dateFormatter.date(from: dateString) else {
                    return false
                }
                
                return date < after2Months
            }
            
            logger.info("\(self.alertUnusedAPIKeys ? "🛡️ Found unused API keys" : "🛡️ No unused API keys found")")
        } catch {
            logger.error("Error fetching API keys: \(error)")
            alertUnusedAPIKeys = false
        }
    }
}
