import Foundation

@Observable
final class UpdateChecker {
    var alertUpdate = false
    
    private struct ItunesAppInfo: Decodable {
        let results: [ItunesAppInfoResult]
    }
    
    private struct ItunesAppInfoResult: Decodable {
        let version: String
    }
    
    func checkForUpdates() async {
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
            print("Update available:", currentVersion, "->", appStoreVersion)
            self.alertUpdate = true
        } else {
            print("The app is up to date")
        }
    }
}
