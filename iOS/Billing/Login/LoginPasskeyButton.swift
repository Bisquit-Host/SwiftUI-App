import SwiftUI

struct LoginPasskeyButton: View {
    @Environment(LoginVM.self) private var vm
    
    let login: String
    let handleAuthResponse: (BillingLoginResponse) -> Void
    
    var body: some View {
        Button(action: loginWithPasskeys) {
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
#if !os(visionOS)
        .glassEffect()
#endif
    }
    
    private func loginWithPasskeys() {
        Task {
            guard let response = await vm.loginWithPasskey(login) else {
                return
            }
            
            handleAuthResponse(response)
        }
    }
}

#Preview {
    LoginPasskeyButton(login: "example@bisquit.host") { _ in }
        .environment(LoginVM())
        .padding()
}
