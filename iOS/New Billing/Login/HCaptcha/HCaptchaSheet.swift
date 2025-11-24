import SwiftUI
import HCaptcha

struct HCaptchaSheet: View {
    @State private var vm = HCaptchaVM()
    @StateObject private var captchaHost = CaptchaHost()
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var hcaptchaToken: String
    
    init(_ hcaptchaToken: Binding<String>) {
        _hcaptchaToken = hcaptchaToken
    }
    
    var body: some View {
        UIViewWrapperView(host: captchaHost)
            .ignoresSafeArea()
            .task {
                vm.configure(captchaHost.view)
                vm.validate(captchaHost.view)
            }
            .onChange(of: vm.token) { _, newToken in
                if let newToken {
                    hcaptchaToken = newToken
                    dismiss()
                } else {
                    print("Invalid token")
                }
            }
    }
}

@Observable
final class HCaptchaVM {
    let hcaptcha: HCaptcha!
    var token: String? = nil
    
    init() {
        self.hcaptcha = try? HCaptcha(
            apiKey: "35f8534a-b950-4dea-b304-9b00f1a0f300",
            baseURL: URL(string: "http://localhost")!,
            size: .normal,
            host: "test-my.bisquit.host",
            theme: "dark"
        )
    }
    
    func configure(_ hostView: UIView) {
        hcaptcha.configureWebView { webview in
            webview.frame = hostView.bounds
        }
        
        hcaptcha.onEvent { event, _ in
            print("HCaptcha event:", event.rawValue)
        }
    }
    
    func validate(_ hostView: UIView) {
        hcaptcha.validate(on: hostView) { result in
            do {
                let token = try result.dematerialize()
                print("HCaptcha result:", token)
                
                self.token = token
            } catch {
                print("Error validating hcaptcha", error.localizedDescription)
            }
        }
    }
}
