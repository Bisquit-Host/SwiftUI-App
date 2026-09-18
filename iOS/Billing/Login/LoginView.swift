import ScrechKit
import BisquitoNet

struct LoginView: View {
    @State private var vm = LoginVM()
    @Environment(OAuthVM.self) private var oauthVM
    @EnvironmentObject private var store: ValueStore

    @State private var sheetDocuments = false
    @State private var sheetHcaptcha = false

    var body: some View {
        @Bindable var vm = vm

        ScrollView {
            VStack {
                if vm.isSignUp {
                    TextField("Name", text: $vm.name)
                        .textContentType(.name)
                        .loginButtonStyle()
                }

                LoginEmailTextField($vm.loginInput)

                if let emailValidationError = vm.emailValidationError {
                    Text(emailValidationError)
                        .footnote()
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                SecureField("Password", text: $vm.password)
                    .textContentType(.password)
                    .loginButtonStyle()
                    .onSubmit(performVerification)

                if vm.isSignUp {
                    RegistrationDocumentsButton($vm.hasAcceptedDocuments, isPresented: $sheetDocuments)
                    LoginCurrencyPicker()
                }

                LoginViewContinueButton(continueButtonDisabled: vm.continueButtonDisabled, isSignUp: vm.isSignUp, performVerification: performVerification)

                ORDivider()

                if !vm.isSignUp {
                    LoginPasskeyButton(login: vm.loginInput, handleAuthResponse: vm.handlePasskeyResponse)
                }

                SocialButtonSection(handleAuthResponse: vm.handleOAuthResponse)

                Button(vm.isSignUp ? "Sign in" : "Register an account") {
                    vm.isSignUp.toggle()
                }
                .secondary()
                .padding(.top)
            }
            .frame(maxWidth: 600)
            .scenePadding()
            .frame(maxWidth: .infinity)
        }
        .defaultScrollAnchor(.center, for: .alignment)
        .scrollIndicators(.hidden)
        .allowsHitTesting(!sheetDocuments)
        .sheet($sheetHcaptcha) {
            HCaptchaSheet($vm.captchaToken)
        }
        .sheet($vm.sheet2FA) {
            Login2FASheetParent(twoFACode: $vm.twoFACode, pending2FAToken: $vm.pending2FAToken, handleAuthResponse: vm.handleAuthResponse)
        }
        .environment(vm)
        .onChange(of: vm.captchaToken) { _, newValue in
            guard !newValue.isEmpty else { return }
            sheetHcaptcha = false
            performVerification()
        }
        .onChange(of: vm.shouldShowCaptcha) { _, newValue in
            guard newValue else { return }
            sheetHcaptcha = true
            vm.shouldShowCaptcha = false
        }
        .onChange(of: vm.sessionToken) { _, token in
            guard let token else { return }

            vm.activateSession(pushToken: store.pushToken)
            if let provider = vm.completedOAuthProvider {
                oauthVM.recordLastUsed(provider)
            }
            store.accessToken = token
        }
        .task {
            await oauthVM.fetchAuthServices()
        }
    }

    private func performVerification() {
        Task {
            await vm.authenticate()
        }
    }

}

#Preview {
    LoginView()
        .darkSchemePreferred()
        .environment(OAuthVM())
        .environmentObject(ValueStore())
}
