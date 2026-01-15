import SwiftUI

struct BillingLoginSocialButtons: View {
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
        VStack(spacing: 6) {
            if isLastUsed {
                Text("Last used")
                    .caption2(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: .capsule)
            }
            
            BillingLoginSocialButton(provider: name, img: img, action: action)
        }
    }
}

#Preview {
    BillingLoginSocialButtons()
        .darkSchemePreferred()
        .environment(OAuthVM())
}
