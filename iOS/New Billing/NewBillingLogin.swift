import SwiftUI
import HCaptcha

struct NewBillingLogin: View {
    @State private var vm = NewBillingLoginVM()
    
    @AppStorage("test_login") private var login = ""
    @AppStorage("test_password") private var password = ""
    
    @State private var sheetHcaptcha = false
    @State private var captchaToken = ""
    
    private var captchaButtonDisabled: Bool {
        login.isEmpty || password.isEmpty
    }
    
    var body: some View {
        VStack {
            TextField("Login", text: $login)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
            
            SecureField("Password", text: $password)
            
            Button("Continue") {
                sheetHcaptcha = true
            }
            .disabled(captchaButtonDisabled)
        }
        .sheet($sheetHcaptcha) {
            HCaptchaSheet($captchaToken)
        }
        .onChange(of: captchaToken) { _, newValue in
            auth()
        }
    }
    
    private func auth() {
        Task {
            await vm.login(login: login, password: password, captchaToken: captchaToken)
        }
    }
}

#Preview {
    NewBillingLogin()
        .darkSchemePreferred()
}
