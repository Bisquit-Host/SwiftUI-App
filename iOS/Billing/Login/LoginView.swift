import ScrechKit
import BisquitoNet

struct LoginView: View {
    @State private var vm = LoginVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var isSignUp = false
    @State private var name = ""
    @State private var login = ""
    @State private var password = ""
    @State private var hasAcceptedDocuments = false
    @State private var captchaToken = ""
    @State private var pending2FAToken: String?
    @State private var twoFACode = ""
    
    // Sheets
    @State private var sheetDocuments = false
    @State private var sheetHcaptcha = false
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
        
        return loginEmpty || passwordEmpty || (isSignUp && nameEmpty) || documentsNotAccepted || invalidEmail || vm.isAttesting
    }
    
    var body: some View {
        VStack {
            if isSignUp {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .loginButtonStyle()
            }
            
            LoginEmailTextField($login)
            
            if let emailValidationError {
                Text(emailValidationError)
                    .footnote()
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .loginButtonStyle()
                .onSubmit(performVerification)
            
            if isSignUp {
                RegistrationDocumentsButton($hasAcceptedDocuments, isPresented: $sheetDocuments)
                LoginCurrencyPicker()
            }
            
            LoginViewContinueButton(continueButtonDisabled: continueButtonDisabled, isSignUp: isSignUp, performVerification: performVerification)
            
            ORDivider()
            
            if !isSignUp {
                LoginPasskeyButton(login: login, handleAuthResponse: handleAuthResponse)
            }
            
            SocialButtonSection(handleAuthResponse: handleAuthResponse)
        }
        .allowsHitTesting(!sheetDocuments)
        .frame(maxWidth: 600, maxHeight: .infinity)
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
            Login2FASheetParent(twoFACode: $twoFACode, pending2FAToken: $pending2FAToken, handleAuthResponse: handleAuthResponse)
        }
        .environment(vm)
        .onChange(of: captchaToken) { _, newValue in
            guard !newValue.isEmpty else { return }
            auth()
        }
        .onChange(of: vm.shouldShowCaptcha) { _, newValue in
            guard newValue else { return }
            sheetHcaptcha = true
            vm.shouldShowCaptcha = false
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
        
        auth()
    }
    
    private func auth() {
        sheetHcaptcha = false
        
        Task {
            let response: BillingSessionAuthResponse?
            
            if isSignUp {
                response = await vm.signup(
                    name: name.trimmingCharacters(in: .whitespaces),
                    email: trimmedLogin,
                    password: password,
                    captchaToken: captchaToken.isEmpty ? nil : captchaToken
                )
            } else {
                response = await vm.login(
                    trimmedLogin,
                    password,
                    captchaToken: captchaToken.isEmpty ? nil : captchaToken
                )
            }
            
            captchaToken = ""
            
            guard let response else { return }
            handleAuthResponse(response)
        }
    }
    
    private func handleAuthResponse(_ response: BillingSessionAuthResponse) {
        if response.twoFa == true {
            pending2FAToken = response.token
            twoFACode = ""
            sheet2FA = true
            return
        }
        
        guard let sessionToken = response.sessionToken?.nonEmpty else {
            SystemAlert.error("Sign-in failed", subtitle: "Session token is missing")
            return
        }
        
        sheet2FA = false
        pending2FAToken = nil
        
        if isSignUp {
            name = ""
        }
        
        saveBillingSessionToken(sessionToken)
        store.accessToken = sessionToken
#if os(iOS)
        Task {
            await PushTokenService.sendIfPossible(accessToken: sessionToken, pushToken: store.pushToken)
        }
#endif
    }
}

#Preview {
    LoginView()
        .darkSchemePreferred()
        .environment(OAuthVM())
        .environmentObject(ValueStore())
}
