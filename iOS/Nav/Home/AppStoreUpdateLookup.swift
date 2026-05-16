import Foundation

enum AppStoreUpdateLookup {
    struct Status: Sendable {
        let currentVersion: String
        let appStoreVersion: String?
        let updateAvailable: Bool
    }
    
    static func check(appID: Int, currentVersion: String? = nil) async throws -> Status? {
        guard let resolvedCurrentVersion = currentVersion ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return nil
        }
        
        guard var components = URLComponents(string: "https://itunes.apple.com/lookup") else {
            return nil
        }
        
        components.queryItems = [
            URLQueryItem(name: "id", value: String(appID))
        ]
        
        guard let url = components.url else {
            return nil
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(Response.self, from: data)
        let appStoreVersion = response.results.first?.version
        let updateAvailable = appStoreVersion.map {
            isUpdateAvailable(currentVersion: resolvedCurrentVersion, appStoreVersion: $0)
        } ?? false
        
        return Status(
            currentVersion: resolvedCurrentVersion,
            appStoreVersion: appStoreVersion,
            updateAvailable: updateAvailable
        )
    }
    
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
        var parts = rawParts.map {
            let digits = $0.prefix { $0.isNumber }
            return Int(digits) ?? 0
        }
        
        while parts.last == 0, parts.count > 1 {
            parts.removeLast()
        }
        
        return parts
    }
}

private extension AppStoreUpdateLookup {
    struct Response: Decodable {
        let results: [Result]
    }
    
    struct Result: Decodable {
        let version: String
    }
}
