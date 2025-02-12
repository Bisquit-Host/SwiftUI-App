import ScrechKit
import PteroNet

@Observable
final class DeepLinkVM {
    var session = ""
    var alertAuth = false
    
    private let tabMapping: [String: Tabs] = [
        "backups": .backup,
        "files": .files,
        "": .info
    ]
    
    func handleDeepLink(_ url: URL) {
        guard url.scheme == "bisq" else {
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }
        
        guard let action = components.host, action == "auth" else {
            print("Unknown URL")
            return
        }
        
        guard let session = components.queryItems?.first(where: { $0.name == "session" })?.value else {
            print("Recipe name not found")
            return
        }
        
        self.session = session
        alertAuth = true
    }
}
