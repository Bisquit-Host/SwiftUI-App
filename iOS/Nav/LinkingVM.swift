import SwiftUI
import PteroNet
import OSLog

@Observable
final class DeepLinkVM {
    private let logger = Logger(subsystem: "host.bisquit.Bisquit-host", category: "DeepLinkVM")
    
    var apiKey = ""
    var alertAuth = false
    
    func handleDeepLink(_ url: URL) {
        guard url.scheme == "bisq", let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            logger.error("🔗 Invalid deeplink URL")
            return
        }
        
        guard let action = components.host, action == "auth" else {
            logger.error("🔗 Unknown deeplink URL")
            return
        }
        
        if let error = components.queryItems?.first(where: { $0.name == "error" })?.value {
            logger.error("🔗 Deeplink error: \(error.replacing("+", with: " "))")
            return
        }
        
        guard let session = components.queryItems?.first(where: { $0.name == "session" || $0.name == "apikey" })?.value else {
            logger.error("🔗 API-key missing")
            return
        }
        
        self.apiKey = session
        alertAuth = true
    }

    func handleUniversalLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            logger.error("🔗 Invalid universal link URL")
            return
        }
        
        if let session = components.queryItems?.first(where: { $0.name == "session" || $0.name == "apikey" })?.value {
            self.apiKey = session
            alertAuth = true
            return
        }
        
        logger.error("🔗 Unknown universal link URL")
    }
}
