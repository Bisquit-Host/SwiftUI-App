import Foundation
import PteroNet

@Observable
final class SecurityTasks {
    var alertUpdate = false
    var alertUnusedAPIKeys = false
    
    func startCheck() async {
        Task {
            try await Task.sleep(for: .seconds(1))
            
            await checkForUpdates()
            await checkForUnusedAPIKeys()
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
            
            print(alertUnusedAPIKeys ? "🛡️ Detected unused API keys" : "🛡️ No unused API keys found")
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
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ItunesAppInfo.self, from: data)
            
            appStoreVersion = decoded.results.first?.version ?? "0"
        } catch {
            return
        }
        
        if currentVersion.compare(appStoreVersion, options: .numeric) == .orderedAscending {
            print("🛡️ Update available:", currentVersion, "->", appStoreVersion)
            self.alertUpdate = true
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
