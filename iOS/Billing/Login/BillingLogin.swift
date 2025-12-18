import Foundation
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
    
    private static let emailRegex = try! NSRegularExpression(pattern: #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#)
    
    private var trimmedLogin: String {
        login.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var emailValidationError: String? {
        guard isSignUp else { return nil }
        guard !trimmedLogin.isEmpty else { return nil }
        return Self.isValidEmail(trimmedLogin) ? nil : "Enter a valid email address"
    }
    
    private var continueButtonDisabled: Bool {
        let loginEmpty = trimmedLogin.isEmpty
        let passwordEmpty = password.trimmingCharacters(in: .whitespaces).isEmpty
        let nameEmpty = name.trimmingCharacters(in: .whitespaces).isEmpty
        let documentsNotAccepted = isSignUp && !hasAcceptedDocuments
        let invalidEmail = isSignUp && !Self.isValidEmail(trimmedLogin)
        
        return loginEmpty || passwordEmpty || (isSignUp && nameEmpty) || documentsNotAccepted || invalidEmail || vm.isSubmitting
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
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .loginButtonStyle()
                .onSubmit {
                    startCaptcha()
                }
            
            if isSignUp {
                RegistrationDocumentsButton($hasAcceptedDocuments, isPresented: $sheetDocuments)
                LoginCurrencyPicker($selectedCurrency)
            }
            
            Button {
                startCaptcha()
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
            .disabled(continueButtonDisabled)
            .opacity(continueButtonDisabled ? 0.3 : 1)
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
            HCaptchaSheet($captchaToken)
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
    
    private static func isValidEmail(_ value: String) -> Bool {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let range = NSRange(value.startIndex..., in: value)
        
        return emailRegex.firstMatch(in: value, options: [], range: range) != nil
    }
    
    private func startCaptcha() {
        guard !continueButtonDisabled else { return }
        sheetHcaptcha = true
    }
    
    private func auth() {
        sheetHcaptcha = false
        
        guard !continueButtonDisabled else {
            captchaToken = ""
            return
        }
        
        Task {
            let response: BillingLoginResponse?
            
            if isSignUp {
                response = await vm.signup(
                    name: name.trimmingCharacters(in: .whitespaces),
                    email: trimmedLogin,
                    password: password,
                    captchaToken: captchaToken,
                    currency: selectedCurrency.rawValue
                )
            } else {
                response = await vm.login(trimmedLogin, password, captchaToken)
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
