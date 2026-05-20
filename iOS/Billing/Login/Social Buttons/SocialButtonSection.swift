import SwiftUI

struct SocialButtonSection: View {
    @Environment(OAuthVM.self) private var vm
    
    var body: some View {
        HStack(alignment: .top) {
            SocialButton(provider: "GitHub", img: .gitHub, isLastUsed: vm.lastUsedProvider == .github) {
                vm.startGitHubLinking()
            }
            
            SocialButton(provider: "Google", img: .google, isLastUsed: vm.lastUsedProvider == .google) {
                vm.startGoogleLinking()
            }
            
            SocialButton(provider: "Yandex", img: .yandex, isLastUsed: vm.lastUsedProvider == .yandex) {
                vm.startYandexLinking()
            }
        }
    }
}

#Preview {
    SocialButtonSection()
        .darkSchemePreferred()
        .environment(OAuthVM())
}
