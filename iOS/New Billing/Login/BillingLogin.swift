import SwiftUI
import HCaptcha

struct BillingLogin: View {
    @State private var vm = BillingLoginVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetHcaptcha = false
    @State private var captchaToken = ""
    @State private var pendingTwoFAToken: String?
    @State private var twoFACode = ""
    @State private var sheetTwoFA = false
    
    private var captchaButtonDisabled: Bool {
        store.login.isEmpty || store.password.isEmpty
    }
    
    var body: some View {
        List {
            TextField("Login", text: $store.login)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
            
            SecureField("Password", text: $store.password)
                .textContentType(.password)
            
            Section {
                Button("Continue") {
                    sheetHcaptcha = true
                }
                .disabled(captchaButtonDisabled)
                
                Button {
                    passkeyLogin()
                } label: {
                    if vm.isPasskeyLoading {
                        HStack {
                            ProgressView()
                            Text("Signing in with passkey...")
                        }
                    } else {
                        Text("Sign in with passkey")
                    }
                }
                .disabled(vm.isPasskeyLoading)
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
        Task {
            guard let response = await vm.login(store.login, store.password, captchaToken) else {
                return
            }
            
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
        
        store.testExpiresIn = response.expiresIn
        store.testRefreshToken = response.refreshToken
        
        Task {
            try await Task.sleep(for: .seconds(0.5))
            
            await MainActor.run {
                withAnimation {
                    store.testAccessToken = response.accessToken
                }
            }
        }
    }
    
    @ViewBuilder
    private var twoFASheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter the 6-digit code from your authenticator app to finish signing in.")
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
}

#Preview {
    BillingLogin()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
