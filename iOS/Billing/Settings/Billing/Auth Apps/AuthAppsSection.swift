import SwiftUI

struct AuthAppsSection: View {
    @Environment(OAuthVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    @Binding private var user: BillingUser?
    
    init(_ user: Binding<BillingUser?>) {
        _user = user
    }
    
    var body: some View {
        if let user {
            BillingSectionCard("Auth apps") {
                AuthSettingsAppCard("GitHub", icon: "app.connected.to.app.below.fill", enabled: !(user.githubId ?? "").isEmpty, isLoading: vm.isLinkingGitHub) {
                    vm.startGitHubLinking {
                        Task {
                            await fetchUserInfo()
                        }
                    }
                } onDisconnect: {
                    await vm.disconnectAuthService("github") {
                        await fetchUserInfo()
                    }
                }
                
                AuthSettingsAppCard("Google", icon: "globe", enabled: !(user.googleId ?? "").isEmpty, isLoading: vm.isLinkingGoogle) {
                    vm.startGoogleLinking {
                        Task {
                            await fetchUserInfo()
                        }
                    }
                } onDisconnect: {
                    await vm.disconnectAuthService("google") {
                        await fetchUserInfo()
                    }
                }
                
                AuthSettingsAppCard("Yandex", icon: "globe", enabled: !(user.yandexId ?? "").isEmpty, isLoading: vm.isLinkingYandex) {
                    vm.startYandexLinking {
                        Task {
                            await fetchUserInfo()
                        }
                    }
                } onDisconnect: {
                    await vm.disconnectAuthService("yandex") {
                        await fetchUserInfo()
                    }
                }
            }
        }
    }
    
    private func fetchUserInfo() async {
        await dashboardVM.fetchUserInfo()
    }
}

#Preview {
    @Previewable @State var user: BillingUser? = .preview
    
    AuthAppsSection($user)
        .darkSchemePreferred()
        .environment(BillingDashboardVM())
        .environment(OAuthVM())
}
