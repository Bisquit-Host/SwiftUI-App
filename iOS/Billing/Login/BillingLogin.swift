import SwiftUI
import HCaptcha
import PteroNet

struct BillingLogin: View {
    @State private var vm = BillingLoginVM()
    @EnvironmentObject private var store: ValueStore
    @Environment(OAuthVM.self) private var oauthVM
    
    @State private var isSignUp = false
    @State private var name = ""
    @State private var login = ""
    @State private var password = ""
    @State private var sheetHcaptcha = false
    @State private var captchaToken = ""
    @State private var pendingTwoFAToken: String?
    @State private var twoFACode = ""
    @State private var sheetTwoFA = false
    
    private var captchaButtonDisabled: Bool {
        let loginEmpty = login.trimmingCharacters(in: .whitespaces).isEmpty
        let passwordEmpty = password.trimmingCharacters(in: .whitespaces).isEmpty
        let nameEmpty = isSignUp && name.trimmingCharacters(in: .whitespaces).isEmpty
        
        return loginEmpty || passwordEmpty || nameEmpty || vm.isSubmitting
    }
    
    var body: some View {
        VStack {
            if isSignUp {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(.primary.opacity(0.04), in: .capsule)
                    .overlay {
                        Capsule()
                            .stroke(.primary.opacity(0.05), lineWidth: 1)
                    }
            }
            
            TextField("Login", text: $login)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding(.horizontal)
                .frame(height: 50)
                .background(.primary.opacity(0.04), in: .capsule)
                .overlay {
                    Capsule()
                        .stroke(.primary.opacity(0.05), lineWidth: 1)
                }
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding(.horizontal)
                .frame(height: 50)
                .background(.primary.opacity(0.04), in: .capsule)
                .overlay {
                    Capsule()
                        .stroke(.primary.opacity(0.05), lineWidth: 1)
                }
                .onSubmit {
                    sheetHcaptcha = true
                }
            
            Button {
                sheetHcaptcha = true
            } label: {
                if vm.isSubmitting {
                    HStack {
                        ProgressView()
                        Text("Please wait...")
                    }
                } else {
                    Text(isSignUp ? "Create account" : "Continue")
                }
            }
            .semibold()
            .rounded()
            .disabled(captchaButtonDisabled)
            .foregroundStyle(.foreground)
            .frame(minHeight: 50)
            .frame(maxWidth: .infinity)
            .glassEffect()
            
            HStack {
                VStack {
                    Divider()
                }
                
                Text("or")
                    .secondary()
                
                VStack {
                    Divider()
                }
            }
            .padding()
            
            if !isSignUp {
                Button(action: passkeyLogin) {
                    if vm.isPasskeyLoading {
                        HStack {
                            ProgressView()
                            Text("Signing in with passkey...")
                        }
                    } else {
                        Label("Sign in with Passkey", systemImage: "person.badge.key.fill")
                            .labelIconToTitleSpacing(10)
                            .semibold()
                            .rounded()
                    }
                }
                .disabled(vm.isPasskeyLoading)
                .foregroundStyle(.foreground)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .glassEffect()
            }
            
            HStack {
                socialButton("GitHub", img: .gitHub, isLoading: oauthVM.isLinkingGitHub) {
                    oauthVM.startGitHubLinking()
                }
                
                socialButton("Google", img: .google, isLoading: oauthVM.isLinkingGoogle) {
                    oauthVM.startGoogleLinking()
                }
                
                socialButton("Yandex", img: .yandex, isLoading: oauthVM.isLinkingYandex) {
                    oauthVM.startYandexLinking()
                }
            }
        }
        .frame(maxHeight: .infinity)
        .scenePadding(.horizontal)
        .overlay(alignment: .bottom) {
            Button(isSignUp ? "Sign in" : "Register an account") {
                withAnimation {
                    isSignUp.toggle()
                }
            }
            .secondary()
        }
        .sheet($sheetHcaptcha) {
            HCaptchaSheet($captchaToken)
        }
        .sheet($sheetTwoFA) {
            NavigationStack {
                BillingTwoFASheet(vm: vm, twoFACode: $twoFACode) {
                    verifyTwoFA()
                }
                .padding()
                .navigationTitle("Enter 2FA code")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onChange(of: captchaToken) { _, newValue in
            guard !newValue.isEmpty else { return }
            auth()
        }
    }
    
    private func auth() {
        sheetHcaptcha = false
        
        Task {
            let response: BillingLoginResponse?
            
            if isSignUp {
                response = await vm.signup(
                    name: name.trimmingCharacters(in: .whitespaces),
                    email: login,
                    password: password,
                    captchaToken: captchaToken
                )
            } else {
                response = await vm.login(login, password, captchaToken)
            }
            
            captchaToken = ""
            
            guard let response else { return }
            
            handleAuthResponse(response)
        }
    }
    
    private func passkeyLogin() {
        Task {
            guard let response = await vm.loginWithPasskey(login: login) else {
                return
            }
            
            handleAuthResponse(response)
        }
    }
    
    private func verifyTwoFA() {
        guard let token = pendingTwoFAToken else {
            return
        }
        
        Task {
            guard let response = await vm.verifyTwoFA(code: twoFACode, token: token) else {
                return
            }
            
            handleAuthResponse(response)
        }
    }
    
    private func handleAuthResponse(_ response: BillingLoginResponse) {
        if response.twoFa == true {
            pendingTwoFAToken = response.token
            twoFACode = ""
            sheetTwoFA = true
            return
        }
        
        sheetTwoFA = false
        pendingTwoFAToken = nil
        
        if isSignUp {
            name = ""
        }
        
        store.testExpiresIn = response.expiresIn
        store.accessToken = response.accessToken
        store.lastBillingTokenRefresh = Date()
        Keychain.save(response.refreshToken, forKey: "refresh_token")
        
        Task {
            try await Task.sleep(for: .seconds(0.5))
            
            withAnimation {
                let _ = Keychain.save(response.accessToken, forKey: "access_token")
            }
        }
    }
    
    private func socialButton(_ provider: String, img: ImageResource, isLoading: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
            } else {
                AuthSocialButtonImage(img)
            }
        }
        .disabled(isLoading)
    }
}

#Preview {
    BillingLogin()
        .darkSchemePreferred()
        .environment(OAuthVM())
        .environmentObject(ValueStore())
}
