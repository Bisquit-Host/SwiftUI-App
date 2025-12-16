import SwiftUI
import HCaptcha
import PteroNet

struct BillingLogin: View {
    @State private var vm = LoginVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var isSignUp = false
    @State private var name = ""
    @State private var login = ""
    @State private var password = ""
    @State private var selectedCurrency: BillingCurrency = .RUB
    @State private var hasAcceptedDocuments = false
    @State private var sheetDocuments = false
    @State private var sheetHcaptcha = false
    @State private var captchaToken = ""
    @State private var pending2FAToken: String?
    @State private var `2FACode` = ""
    @State private var sheet2FA = false
    
    private var captchaButtonDisabled: Bool {
        let loginEmpty = login.trimmingCharacters(in: .whitespaces).isEmpty
        let passwordEmpty = password.trimmingCharacters(in: .whitespaces).isEmpty
        let nameEmpty = isSignUp && name.trimmingCharacters(in: .whitespaces).isEmpty
        let documentsNotAccepted = isSignUp && !hasAcceptedDocuments
        
        return loginEmpty || passwordEmpty || nameEmpty || documentsNotAccepted || vm.isSubmitting
    }
    
    var body: some View {
        VStack {
            if isSignUp {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .loginTextField()
            }
            
            TextField("Login", text: $login)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .loginTextField()
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .loginTextField()
                .onSubmit {
                    sheetHcaptcha = true
                }
            
            if isSignUp {
                HStack {
                    Text("Currency")
                        .secondary()
                    
                    Spacer(minLength: 100)
                    
                    Picker(selection: $selectedCurrency) {
                        ForEach(BillingCurrency.allCases, id: \.self) {
                            Text("\($0.symbol) \($0.rawValue)")
                                .tag($0)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("\(selectedCurrency.symbol) \(selectedCurrency.rawValue)")
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .footnote()
                                .secondary()
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(.primary)
                }
                .loginTextField()
                
                Button {
                    sheetDocuments = true
                } label: {
                    HStack {
                        Text(hasAcceptedDocuments ? "Documents accepted" : "Review & accept documents")
                        
                        Spacer()
                        
                        Image(systemName: hasAcceptedDocuments ? "checkmark.circle.fill" : "doc.text")
                            .secondary()
                    }
                }
                .secondary()
                .frame(maxWidth: .infinity)
                .loginTextField()
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
            
            LoginDivider()
            
            if !isSignUp {
                LoginPasskeyButton(login: login, handleAuthResponse: handleAuthResponse)
            }
            
            BillingLoginSocialButtons()
        }
        .frame(maxHeight: .infinity)
        .scenePadding(.horizontal)
        .overlay(alignment: .bottom) {
            Button(isSignUp ? "Sign in" : "Register an account") {
                isSignUp.toggle()
            }
            .secondary()
        }
        .sheet($sheetHcaptcha) {
            HCaptchaSheet($captchaToken)
        }
        .sheet($sheetDocuments) {
            NavigationStack {
                LoginSignupDocumentList($hasAcceptedDocuments)
            }
        }
        .sheet($sheet2FA) {
            NavigationStack {
                Login2FASheet($2FACode) {
                    await verifyTwoFA()
                }
                .padding()
                .navigationTitle("Enter 2FA code")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .environment(vm)
        .onChange(of: captchaToken) { _, newValue in
            guard !newValue.isEmpty else { return }
            auth()
        }
        .onChange(of: isSignUp) { _, newValue in
            if !newValue {
                hasAcceptedDocuments = false
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
    
    private func verifyTwoFA() async {
        guard
            let pending2FAToken,
            let response = await vm.verify2FA(code: `2FACode`, token: pending2FAToken)
        else {
            return
        }
        
        handleAuthResponse(response)
    }
    
    private func handleAuthResponse(_ response: BillingLoginResponse) {
        if response.twoFa == true {
            pending2FAToken = response.token
            `2FACode` = ""
            sheet2FA = true
            return
        }
        
        sheet2FA = false
        pending2FAToken = nil
        
        if isSignUp {
            name = ""
        }
        
        store.accessTokenExpiresIn = response.expiresIn
        store.accessToken = response.accessToken
        store.lastBillingTokenRefresh = Date()
        
        Keychain.save(response.refreshToken, forKey: "refresh_token")
        
        Task {
            try await Task.sleep(for: .seconds(0.5))
            
            let _ = Keychain.save(response.accessToken, forKey: "access_token")
        }
    }
}

#Preview {
    BillingLogin()
        .darkSchemePreferred()
        .environment(OAuthVM())
        .environmentObject(ValueStore())
}
