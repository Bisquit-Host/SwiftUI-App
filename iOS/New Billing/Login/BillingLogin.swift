import SwiftUI
import HCaptcha

struct BillingLogin: View {
    @State private var vm = BillingLoginVM()
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetHcaptcha = false
    @State private var captchaToken = ""
    
    private var captchaButtonDisabled: Bool {
        store.login.isEmpty || store.password.isEmpty
    }
    
    var body: some View {
        VStack {
            TextField("Login", text: $store.login)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
            
            SecureField("Password", text: $store.password)
            
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
            if let response = await vm.login(store.login, store.password, captchaToken) {
                store.testExpiresIn = response.expiresIn
                store.testAccessToken = response.accessToken
                store.testRefreshToken = response.refreshToken
                
                nav.navigate(.toBillingDashboard)
            }
        }
    }
}

#Preview {
    BillingLogin()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
