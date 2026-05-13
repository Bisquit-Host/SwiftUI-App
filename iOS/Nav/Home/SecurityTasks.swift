import Foundation
import PteroNet

@Observable
final class SecurityTasks {
    var alertUpdate = false
    var alertUnusedAPIKeys = false
    var alertTwoFA = false
    
    private let logger = Logger(subsystem: "host.bisquit.Bisquit-host", category: "SecurityTasks")
    
    static func isUpdateAvailable(currentVersion: String, appStoreVersion: String) -> Bool {
        let currentParts = versionComponents(from: currentVersion)
        let storeParts = versionComponents(from: appStoreVersion)
        
        for (current, store) in zip(currentParts, storeParts) {
            if current != store {
                return current < store
            }
        }
        
        return currentParts.count < storeParts.count
    }
    
    private static func versionComponents(from version: String) -> [Int] {
        let rawParts = version.split(separator: ".")
        
        let parts = rawParts.map { part -> Int in
            let digits = part.prefix { $0.isNumber }
            return Int(digits) ?? 0
        }
        
        var trimmed = parts
        
        while trimmed.last == 0, trimmed.count > 1 {
            trimmed.removeLast()
        }
        
        return trimmed
    }
    
    func startCheck() async {
        Task {
            try await Task.sleep(for: .seconds(1))
            
            async let updates: () = await checkForUpdates()
            async let keys: () = await checkForUnusedAPIKeys()
            async let twoFA: () = await checkForTwoFA()
            
            let _ = await (updates, keys, twoFA)
        }
    }
    
    private func checkForTwoFA() async {
        do {
            // If details are returned, 2FA is currently disabled and should be enabled
            let _ = try await twoFaDetailtsAPI()
            alertTwoFA = true
            logger.info("🛡️ 2FA disabled")
            
        } catch TwoFAError.alreadyEnabled {
            alertTwoFA = false
            logger.info("🛡️ 2FA enabled")
            
        } catch {
            logger.error("Error checking 2FA status: \(error)")
            alertTwoFA = false
        }
    }
    
    private func checkForUnusedAPIKeys() async {
        do {
            let apiKeys = try await apiKeyListAPI().map(\.attributes)
            
            guard let after2Months = Calendar.current.date(byAdding: .month, value: -2, to: Date()) else {
                return
            }
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime]
            
            alertUnusedAPIKeys = apiKeys.contains { key in
                let dateString = key.lastUsed ?? key.created
                
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
    
    private func checkForUpdates() async {
        let path = "https://itunes.apple.com/lookup?id=1639409934"
        
        guard let currentVersion = Bundle.version, let url = URL(string: path) else {
            return
        }
        
        let req = URLRequest(url: url)
        var appStoreVersion = "0"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let decoded = try BigAssDecoder.decode(ItunesAppInfo.self, from: data)
            
            appStoreVersion = decoded.results.first?.version ?? "0"
        } catch {
            return
        }
        
        if Self.isUpdateAvailable(currentVersion: currentVersion, appStoreVersion: appStoreVersion) {
            logger.info("🛡️ Update available: \(currentVersion) -> \(appStoreVersion)")
            alertUpdate = true
        } else {
            logger.info("🛡️ The app is up to date")
        }
    }
}

fileprivate struct ItunesAppInfo: Decodable {
    let results: [ItunesAppInfoResult]
    
    struct ItunesAppInfoResult: Decodable {
        let version: String
    }
}
