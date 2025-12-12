import SwiftUI

struct BillingLoginSocialButtons: View {
    @Environment(OAuthVM.self) private var vm
    
    var body: some View {
        HStack {
            BillingLoginSocialButton("GitHub", img: .gitHub, isLoading: vm.isLinkingGitHub) {
                vm.startGitHubLinking()
            }
            
            BillingLoginSocialButton("Google", img: .google, isLoading: vm.isLinkingGoogle) {
                vm.startGoogleLinking()
            }
            
            BillingLoginSocialButton("Yandex", img: .yandex, isLoading: vm.isLinkingYandex) {
                vm.startYandexLinking()
            }
        }
    }
}

#Preview {
    BillingLoginSocialButtons()
        .darkSchemePreferred()
        .environment(OAuthVM())
}
