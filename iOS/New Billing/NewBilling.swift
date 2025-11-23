import SwiftUI
import HCaptcha

struct NewBilling: View {
    @StateObject private var captchaVM = HCaptchaVM()
    private let placeholder = UIViewWrapperView()
    
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
                placeholder
                    .frame(width: 640, height: 640, alignment: .center)
                
                Button("validate") {
                    captchaVM.validate(placeholder)
                }
                .padding()
            }
        }
        .onAppear {
            captchaVM.configure(placeholder)
        }
    }
}

// Wrapper-view to provide UIView instance
struct UIViewWrapperView: UIViewRepresentable {
    var uiView = UIView()
    
    func makeUIView(context: Context) -> UIView {
        uiView.backgroundColor = .gray
        return uiView
    }
    
    func updateUIView(_ view: UIView, context: Context) {}
}

class HCaptchaVM: ObservableObject {
    let hcaptcha: HCaptcha!
    
    init() {
        self.hcaptcha = try? HCaptcha(
            apiKey: "35f8534a-b950-4dea-b304-9b00f1a0f300",
            baseURL: URL(string: "http://localhost")!,
            //            baseURL: URL(string: "https://api.hcaptcha.com/siteverify")!
            size: .normal,
            host: "test-my.bisquit.host"
        )
    }
    
    func configure(_ hostView: UIViewWrapperView) {
        hcaptcha.configureWebView { webview in
            webview.frame = hostView.uiView.bounds
        }
        
        hcaptcha.onEvent { event, _ in
            print("HCaptcha onEvent:", event.rawValue)
        }
    }
    
    func validate(_ hostView: UIViewWrapperView) {
        hcaptcha.validate(on: hostView.uiView) { result in
            print("HCaptcha result:", String(describing: try? result.dematerialize()))
        }
    }
}

#Preview {
    NewBilling()
        .darkSchemePreferred()
}
