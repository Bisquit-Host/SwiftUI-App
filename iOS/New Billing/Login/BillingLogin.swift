import SwiftUI
import HCaptcha

struct BillingLogin: View {
    @State private var vm = BillingLoginVM()
    @EnvironmentObject private var store: ValueStore
    @Environment(OAuthVM.self) private var oauthVM
    
    @State private var isSignUp = false
    @State private var name = ""
    @State private var sheetHcaptcha = false
    @State private var captchaToken = ""
    @State private var pendingTwoFAToken: String?
    @State private var twoFACode = ""
    @State private var sheetTwoFA = false
    
    private var captchaButtonDisabled: Bool {
        let loginEmpty = store.login.trimmingCharacters(in: .whitespaces).isEmpty
        let passwordEmpty = store.password.trimmingCharacters(in: .whitespaces).isEmpty
        let nameEmpty = isSignUp && name.trimmingCharacters(in: .whitespaces).isEmpty
        
        return loginEmpty || passwordEmpty || nameEmpty || vm.isSubmitting
    }
    
    var body: some View {
        ScrollView {
            Section {
                Picker("Mode", selection: $isSignUp) {
                    Text("Sign in").tag(false)
                    Text("Sign up").tag(true)
                }
                .pickerStyle(.segmented)
            }
            
            if isSignUp {
                TextField("Name", text: $name)
                    .textContentType(.name)
            }
            
            TextField("Login", text: $store.login)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding(12)
                .background(.primary.opacity(0.04), in: .capsule)
                .overlay {
                    Capsule()
                        .stroke(.primary.opacity(0.05), lineWidth: 1)
                }
                .frame(height: 50)
            
            SecureField("Password", text: $store.password)
                .textContentType(.password)
                .padding(12)
                .background(.primary.opacity(0.04), in: .capsule)
                .overlay {
                    Capsule()
                        .stroke(.primary.opacity(0.05), lineWidth: 1)
                }
                .frame(height: 50)
            
            Section {
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
                    Button {
                        passkeyLogin()
                    } label: {
                        if vm.isPasskeyLoading {
                            HStack {
                                ProgressView()
                                Text("Signing in with passkey...")
                            }
                        } else {
                            Label("Sign in with passkey", systemImage: "person.badge.key.fill")
                                .labelIconToTitleSpacing(10)
                                .semibold()
                                .rounded()
                        }
                    }
                    .disabled(vm.isPasskeyLoading)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .glassEffect()
                    .foregroundStyle(.foreground)
                }
            }
            
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
        .sheet($sheetHcaptcha) {
            HCaptchaSheet($captchaToken)
        }
        .sheet($sheetTwoFA) {
            NavigationStack {
                twoFASheet
                    .padding()
                    .navigationTitle("Enter 2FA code")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onChange(of: captchaToken) { _, newValue in
            guard !newValue.isEmpty else { return }
            auth()
        }
        .alert("Passkey error", isPresented: Binding(get: {
            vm.passkeyError != nil
        }, set: { newValue in
            if !newValue {
                vm.passkeyError = nil
            }
        })) {
            Button("OK", role: .cancel) {
                vm.passkeyError = nil
            }
        } message: {
            if let passkeyError = vm.passkeyError {
                Text(passkeyError)
            }
        }
    }
    
    private func auth() {
        sheetHcaptcha = false
        
        Task {
            let response: BillingLoginResponse?
            
            if isSignUp {
                response = await vm.signup(
                    name: name.trimmingCharacters(in: .whitespaces),
                    email: store.login,
                    password: store.password,
                    captchaToken: captchaToken
                )
            } else {
                response = await vm.login(store.login, store.password, captchaToken)
            }
            
            captchaToken = ""
            
            guard let response else { return }
            
            handleAuthResponse(response)
        }
    }
    
    private func passkeyLogin() {
        Task {
            guard let response = await vm.loginWithPasskey(login: store.login) else {
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
        store.testRefreshToken = response.refreshToken
        
        Task {
            try await Task.sleep(for: .seconds(0.5))
            
            withAnimation {
                store.testAccessToken = response.accessToken
            }
        }
    }
    
    @ViewBuilder
    private var twoFASheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter the 6-digit code from your authenticator app to finish signing in")
                .secondary()
                .footnote()
            
            TextField("123456", text: $twoFACode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .onSubmit {
                    verifyTwoFA()
                }
            
            if let twoFAError = vm.twoFAError {
                Text(twoFAError)
                    .foregroundStyle(.red)
                    .footnote()
            }
            
            Button {
                verifyTwoFA()
            } label: {
                if vm.isVerifyingTwoFA {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Verify and continue")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(twoFACode.trimmingCharacters(in: .whitespaces).count < 6 || vm.isVerifyingTwoFA)
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
