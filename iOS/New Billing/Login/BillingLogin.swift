import SwiftUI
import HCaptcha

struct BillingLogin: View {
    @State private var vm = BillingLoginVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetHcaptcha = false
    @State private var captchaToken = ""
    
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
            
            store.testExpiresIn = response.expiresIn
            store.testRefreshToken = response.refreshToken
            
            try await Task.sleep(for: .seconds(0.5))
            
            withAnimation {
                store.testAccessToken = response.accessToken
            }
        }
    }

    private func passkeyLogin() {
        Task {
            guard let response = await vm.loginWithPasskey(login: store.login) else {
                return
            }

            await MainActor.run {
                store.testExpiresIn = response.expiresIn
                store.testRefreshToken = response.refreshToken
                store.testAccessToken = response.accessToken
            }
        }
    }
}

#Preview {
    BillingLogin()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
