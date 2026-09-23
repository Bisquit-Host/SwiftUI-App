import ScrechKit
import BisquitoNet

struct LoginPasskeyButton: View {
    @Environment(LoginVM.self) private var vm
    @Environment(OAuthVM.self) private var oauthVM
    
    let login: String
    let handleAuthResponse: (BillingSessionAuthResponse) -> Void
    
    var body: some View {
        AsyncButton(action: loginWithPasskeys) {
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
        .overlay(alignment: .topTrailing) {
            if oauthVM.isPasskeyLastUsed {
                SocialButtonBadge()
            }
        }
    }
    
    private func loginWithPasskeys() async {
        guard let response = await vm.loginWithPasskey(login) else {
            return
        }
        
        handleAuthResponse(response)
    }
}

#Preview {
    LoginPasskeyButton(login: "example@bisquit.host") { _ in }
        .environment(LoginVM())
        .environment(OAuthVM())
        .padding()
}
