import SwiftUI
//import HCaptcha
import PteroNet
import BisquitoNet

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
    
    private let emailRegex = try! NSRegularExpression(pattern: #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#)
    
    private var trimmedLogin: String {
        login.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var emailValidationError: String? {
        guard isSignUp else { return nil }
        guard !trimmedLogin.isEmpty else { return nil }
        
        return isValidEmail(trimmedLogin) ? nil : "Enter a valid email address"
    }
    
    private var continueButtonDisabled: Bool {
        let loginEmpty = trimmedLogin.isEmpty
        let passwordEmpty = password.trimmingCharacters(in: .whitespaces).isEmpty
        let nameEmpty = name.trimmingCharacters(in: .whitespaces).isEmpty
        let documentsNotAccepted = isSignUp && !hasAcceptedDocuments
        let invalidEmail = isSignUp && !isValidEmail(trimmedLogin)
        
        return loginEmpty || passwordEmpty || (isSignUp && nameEmpty) || documentsNotAccepted || invalidEmail || vm.isSubmitting || vm.isAttesting
    }
    
    var body: some View {
        VStack {
            if isSignUp {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .loginButtonStyle()
            }
            
            TextField(isSignUp ? "Email" : "Login", text: $login)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .loginButtonStyle()
            
            if let emailValidationError {
                Text(emailValidationError)
                    .footnote()
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .loginButtonStyle()
                .onSubmit {
                    performVerification()
                }
            
            if isSignUp {
                RegistrationDocumentsButton($hasAcceptedDocuments, isPresented: $sheetDocuments)
                LoginCurrencyPicker($selectedCurrency)
            }
            
            Button(action: performVerification) {
                if vm.isAttesting {
                    HStack {
                        ProgressView()
                        Text("Verifying...")
                    }
                } else if vm.isSubmitting {
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
            .disabled(continueButtonDisabled)
            .opacity(continueButtonDisabled ? 0.3 : 1)
            .foregroundStyle(.foreground)
            .frame(minHeight: 50)
            .frame(maxWidth: .infinity)
#if !os(visionOS)
            .glassEffect()
#endif
            LoginDivider()
            
            if !isSignUp {
                LoginPasskeyButton(login: login, handleAuthResponse: handleAuthResponse)
            }
            
            BillingLoginSocialButtons()
        }
        .allowsHitTesting(!sheetDocuments)
        .frame(maxHeight: .infinity)
        .scenePadding(.horizontal)
        .overlay(alignment: .bottom) {
            Button(isSignUp ? "Sign in" : "Register an account") {
                isSignUp.toggle()
            }
            .secondary()
        }
        .sheet($sheetHcaptcha) {
#if !os(visionOS)
            HCaptchaSheet($captchaToken)
#endif
        }
        .sheet($sheet2FA) {
            NavigationStack {
                Login2FASheet(`2FACode`: $2FACode, pending2FAToken: $pending2FAToken, handleAuthResponse: handleAuthResponse)
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
    
    private func isValidEmail(_ value: String) -> Bool {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let range = NSRange(value.startIndex..., in: value)
        
        return emailRegex.firstMatch(in: value, options: [], range: range) != nil
    }
    
    private func performVerification() {
        guard !continueButtonDisabled else { return }
        
        Task {
            let userID = trimmedLogin.isEmpty ? nil : trimmedLogin
            
            if vm.isAppAttestSupported, let _ = await vm.performAppAttest(userID: userID) {
                auth()
            } else {
                sheetHcaptcha = true
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
                    email: trimmedLogin,
                    password: password,
                    captchaToken: captchaToken.isEmpty ? nil : captchaToken,
                    currency: selectedCurrency.rawValue,
                    attestResponse: vm.attestationResult
                )
            } else {
                response = await vm.login(
                    trimmedLogin,
                    password,
                    captchaToken: captchaToken.isEmpty ? nil : captchaToken,
                    attestResponse: vm.attestationResult
                )
            }
            
            captchaToken = ""
            vm.attestationResult = nil
            
            guard let response else { return }
            handleAuthResponse(response)
        }
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
