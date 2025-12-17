import SwiftUI
import PteroNet

@Observable
final class DeepLinkVM {
    var apiKey = ""
    var alertAuth = false
    
    func handleDeepLink(_ url: URL) {
        guard url.scheme == "bisq", let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("🔗 Invalid deeplink URL")
            return
        }
        
        guard let action = components.host, action == "auth" else {
            print("🔗 Unknown deeplink URL")
            return
        }
        
        if let error = components.queryItems?.first(where: { $0.name == "error" })?.value {
            print("🔗 Deeplink error:", error.replacing("+", with: " "))
            return
        }
        
        guard let session = components.queryItems?.first(where: { $0.name == "session" || $0.name == "apikey" })?.value else {
            print("🔗 API-key missing")
            return
        }
        
        self.apiKey = session
        alertAuth = true
    }
}
