import SwiftUI

struct BillingLoginSocialButtons: View {
    @Environment(OAuthVM.self) private var vm
    
    var body: some View {
        HStack {
            BillingLoginSocialButton(provider: "GitHub", img: .gitHub) {
                vm.startGitHubLinking()
            }
            
            BillingLoginSocialButton(provider: "Google", img: .google) {
                vm.startGoogleLinking()
            }
            
            BillingLoginSocialButton(provider: "Yandex", img: .yandex) {
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
