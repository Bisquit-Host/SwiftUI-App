import Foundation

@Observable
final class UpdateChecker {
    var alertUpdate = false
    
    func checkForUpdates() async {
        let decoder = JSONDecoder()
        var appStoreVersion = "0"
        
        guard
            let currentVersion = Bundle.version,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=host.bisquit.Bisquit-Host")
        else {
            return
        }
        
        let request = URLRequest(url: url)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
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
    
    struct ItunesAppInfo: Decodable {
        let results: [ItunesAppInfoResult]
    }
    
    struct ItunesAppInfoResult: Decodable {
        let version: String
    }
}
