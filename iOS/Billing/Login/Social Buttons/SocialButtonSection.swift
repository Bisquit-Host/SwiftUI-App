import SwiftUI
import BisquitoNet

struct SocialButtonSection: View {
    @Environment(OAuthVM.self) private var oauthVM
    @Environment(LoginVM.self) private var loginVM
    
    let handleAuthResponse: (BillingSessionAuthResponse) -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            SocialButton(
                provider: "Apple",
                systemImage: "apple.logo",
                isLastUsed: oauthVM.isLastUsedApple,
                isEnabled: oauthVM.isAuthServiceAvailable(.apple)
            ) {
                loginWithApple()
            }
            
            SocialButton(
                provider: "Google",
                img: .google,
                isLastUsed: oauthVM.lastUsedProvider == .google,
                isEnabled: oauthVM.isAuthServiceAvailable(.google)
            ) {
                oauthVM.startGoogleLinking()
            }
            
            SocialButton(
                provider: "GitHub",
                img: .gitHub,
                isLastUsed: oauthVM.lastUsedProvider == .github,
                isEnabled: oauthVM.isAuthServiceAvailable(.github)
            ) {
                oauthVM.startGitHubLinking()
            }
            
            SocialButton(
                provider: "Yandex",
                img: .yandex,
                isLastUsed: oauthVM.lastUsedProvider == .yandex,
                isEnabled: oauthVM.isAuthServiceAvailable(.yandex)
            ) {
                oauthVM.startYandexLinking()
            }
        }
    }
    
    private func loginWithApple() {
        Task {
            guard let response = await loginVM.loginWithApple() else {
                return
            }
            
            handleAuthResponse(response)
        }
    }
}

#Preview {
    SocialButtonSection { _ in }
        .darkSchemePreferred()
        .environment(LoginVM())
        .environment(OAuthVM())
        .environmentObject(ValueStore())
}
