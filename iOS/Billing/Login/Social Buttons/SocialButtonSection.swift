import SwiftUI

struct SocialButtonSection: View {
    @Environment(OAuthVM.self) private var oauthVM
    @Environment(LoginVM.self) private var loginVM
    
    let handleAuthResponse: (BillingSessionAuthResponse) -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            SocialButton(provider: "Apple", systemImage: "apple.logo", isLastUsed: oauthVM.isLastUsedApple) {
                loginWithApple()
            }
            
            SocialButton(provider: "Google", img: .google, isLastUsed: oauthVM.lastUsedProvider == .google) {
                oauthVM.startGoogleLinking()
            }
            
            SocialButton(provider: "GitHub", img: .gitHub, isLastUsed: oauthVM.lastUsedProvider == .github) {
                oauthVM.startGitHubLinking()
            }
            
            SocialButton(provider: "Yandex", img: .yandex, isLastUsed: oauthVM.lastUsedProvider == .yandex) {
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
}
