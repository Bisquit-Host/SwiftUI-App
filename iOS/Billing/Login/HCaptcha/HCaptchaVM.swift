import SwiftUI
import HCaptcha
import OSLog

@Observable
final class HCaptchaVM {
    let hcaptcha: HCaptcha!
    var token: String? = nil
    var isLoading = true
    
    init() {
        self.hcaptcha = try? HCaptcha(
            apiKey: "35f8534a-b950-4dea-b304-9b00f1a0f300",
            baseURL: URL(string: "http://localhost")!,
            host: "my.bisquit.host",
            theme: "dark"
        )
    }
    
    func configure(_ hostView: UIView) {
        hcaptcha.configureWebView { webview in
            webview.frame = hostView.bounds
        }
        
        hcaptcha.onEvent { event, _ in
            Logger().info("HCaptcha event: \(event.rawValue)")
            self.isLoading = false
        }
    }
    
    func validate(_ hostView: UIView) {
        hcaptcha.validate(on: hostView) { result in
            do {
                let token = try result.dematerialize()
                Logger().info("HCaptcha result: \(token)")
                
                self.token = token
                self.isLoading = false
            } catch {
                Logger().error("Error validating hcaptcha: \(error)")
                self.isLoading = false
            }
        }
    }
}
