import SwiftUI
import HCaptcha

final class CaptchaHost: ObservableObject {
    let view = UIView()
}

struct NewBilling: View {
    @StateObject private var captchaVM = HCaptchaVM()
    @StateObject private var captchaHost = CaptchaHost()
    
    @AppStorage("test_login") private var login = ""
    @AppStorage("test_password") private var password = ""
    
    var body: some View {
        VStack {
            TextField("Login", text: $login)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            
            SecureField("Password", text: $password)
            
            VStack {
                UIViewWrapperView(host: captchaHost)
                    .frame(width: 640, height: 640, alignment: .center)
                
                Button("validate") {
                    captchaVM.validate(captchaHost.view)
                }
                .padding()
            }
        }
        .task {
            captchaVM.configure(captchaHost.view)
        }
    }
}

// Wrapper-view to provide UIView instance
struct UIViewWrapperView: UIViewRepresentable {
    @ObservedObject var host: CaptchaHost
    
    func makeUIView(context: Context) -> UIView {
        host.view.backgroundColor = .gray
        return host.view
    }
    
    func updateUIView(_ view: UIView, context: Context) {}
}

class HCaptchaVM: ObservableObject {
    let hcaptcha: HCaptcha!
    
    init() {
        self.hcaptcha = try? HCaptcha(
            apiKey: "35f8534a-b950-4dea-b304-9b00f1a0f300",
            baseURL: URL(string: "http://localhost")!,
            size: .normal,
            host: "test-my.bisquit.host"
        )
    }
    
    func configure(_ hostView: UIView) {
        hcaptcha.configureWebView { webview in
            webview.frame = hostView.bounds
        }
        
        hcaptcha.onEvent { event, _ in
            print("HCaptcha onEvent:", event.rawValue)
        }
    }
    
    func validate(_ hostView: UIView) {
        hcaptcha.validate(on: hostView) { result in
            print("HCaptcha result:", String(describing: try? result.dematerialize()))
        }
    }
}

#Preview {
    NewBilling()
        .darkSchemePreferred()
}
