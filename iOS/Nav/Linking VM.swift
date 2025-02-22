import ScrechKit
import PteroNet

@Observable
final class DeepLinkVM {
    var session = ""
    var alertAuth = false
    
    func handleDeepLink(_ url: URL) {
        print("Deeplink:", url)
        
        guard
            url.scheme == "bisq",
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else {
            print("Invalid URL")
            return
        }
        
        guard
            let action = components.host,
            action == "auth"
        else {
            print("Unknown URL")
            return
        }
        
        guard
            let session = components.queryItems?.first(where: { $0.name == "session" || $0.name == "apikey" })?.value
        else {
            print("Recipe name not found")
            return
        }
        
        self.session = session
        alertAuth = true
    }
}
