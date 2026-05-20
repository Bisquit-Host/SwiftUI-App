import SwiftUI

struct LoginViewSocialButtons: View {
    @Environment(OAuthVM.self) private var vm
    
    var body: some View {
        HStack(alignment: .top) {
            providerButton("GitHub", img: .gitHub, isLastUsed: vm.lastUsedProvider == .github) {
                vm.startGitHubLinking()
            }
            
            providerButton("Google", img: .google, isLastUsed: vm.lastUsedProvider == .google) {
                vm.startGoogleLinking()
            }
            
            providerButton("Yandex", img: .yandex, isLastUsed: vm.lastUsedProvider == .yandex) {
                vm.startYandexLinking()
            }
        }
    }
    
    private func providerButton(_ name: String, img: ImageResource, isLastUsed: Bool, action: @escaping () -> Void) -> some View {
        LoginViewSocialButton(provider: name, img: img, action: action)
            .overlay(alignment: .bottom) {
                if isLastUsed {
                    Text("Last used")
                        .caption2(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
#if !os(visionOS)
                        .glassEffect()
#endif
                        .offset(y: 14)
                }
            }
    }
}

#Preview {
    LoginViewSocialButtons()
        .darkSchemePreferred()
        .environment(OAuthVM())
}
