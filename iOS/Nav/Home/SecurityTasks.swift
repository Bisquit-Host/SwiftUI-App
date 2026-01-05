import Foundation
import PteroNet

@Observable
final class SecurityTasks {
    var alertUpdate = false
    var alertUnusedAPIKeys = false
    var alertTwoFA = false
    
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
            print("🛡️ 2FA is disabled")
            
        } catch TwoFAError.alreadyEnabled {
            alertTwoFA = false
            print("🛡️ 2FA enabled")
            
        } catch {
            print("Error checking 2FA status:", error.localizedDescription)
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
            
            print(alertUnusedAPIKeys ? "🛡️ Found unused API keys" : "🛡️ No unused API keys found")
        } catch {
            print("Error fetching API keys:", error.localizedDescription)
            alertUnusedAPIKeys = false
        }
    }
    
    private func checkForUpdates() async {
        let path = "https://itunes.apple.com/lookup?bundleId=host.bisquit.Bisquit-Host"
        
        guard let currentVersion = Bundle.version, let url = URL(string: path) else {
            return
        }
        
        let request = URLRequest(url: url)
        var appStoreVersion = "0"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoded = try BigAssDecoder.decode(ItunesAppInfo.self, from: data)
            
            appStoreVersion = decoded.results.first?.version ?? "0"
        } catch {
            return
        }
        
        if currentVersion.compare(appStoreVersion, options: .numeric) == .orderedAscending {
            print("🛡️ Update available:", currentVersion, "->", appStoreVersion)
            alertUpdate = true
        } else {
            print("🛡️ The app is up to date")
        }
    }
}

fileprivate struct ItunesAppInfo: Decodable {
    let results: [ItunesAppInfoResult]
    
    struct ItunesAppInfoResult: Decodable {
        let version: String
    }
}
