import SwiftUI
import BisquitoNet

struct AuthAppsSection: View {
    @Environment(OAuthVM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
    
    @Binding private var user: BillingUser?
    
    init(_ user: Binding<BillingUser?>) {
        _user = user
    }
    
    var body: some View {
        if let user {
            BillingSectionCard("Auth apps") {
                AuthSettingsAppCard(
                    "Apple",
                    icon: "apple.logo",
                    enabled: !(user.appleId ?? "").isEmpty,
                    isAvailable: vm.isAuthServiceAvailable(.apple),
                    isLoading: vm.isLinkingApple || vm.isLoadingAuthServices
                ) {
                    vm.startAppleLinking {
                        await dashboardVM.fetchUserInfo()
                    }
                } onDisconnect: {
                    await vm.disconnectAuthService("apple") {
                        await dashboardVM.fetchUserInfo()
                    }
                }
                
                AuthSettingsAppCard(
                    "Google",
                    icon: "globe",
                    enabled: !(user.googleId ?? "").isEmpty,
                    isAvailable: vm.isAuthServiceAvailable(.google),
                    isLoading: vm.isLinkingGoogle || vm.isLoadingAuthServices
                ) {
                    vm.startGoogleLinking {
                        await dashboardVM.fetchUserInfo()
                    }
                } onDisconnect: {
                    await vm.disconnectAuthService("google") {
                        await dashboardVM.fetchUserInfo()
                    }
                }
                
                AuthSettingsAppCard(
                    "GitHub",
                    icon: "app.connected.to.app.below.fill",
                    enabled: !(user.githubId ?? "").isEmpty,
                    isAvailable: vm.isAuthServiceAvailable(.github),
                    isLoading: vm.isLinkingGitHub || vm.isLoadingAuthServices
                ) {
                    vm.startGitHubLinking {
                        await dashboardVM.fetchUserInfo()
                    }
                } onDisconnect: {
                    await vm.disconnectAuthService("github") {
                        await dashboardVM.fetchUserInfo()
                    }
                }
                
                AuthSettingsAppCard(
                    "Yandex",
                    icon: "globe",
                    enabled: !(user.yandexId ?? "").isEmpty,
                    isAvailable: vm.isAuthServiceAvailable(.yandex),
                    isLoading: vm.isLinkingYandex || vm.isLoadingAuthServices
                ) {
                    vm.startYandexLinking {
                        await dashboardVM.fetchUserInfo()
                    }
                } onDisconnect: {
                    await vm.disconnectAuthService("yandex") {
                        await dashboardVM.fetchUserInfo()
                    }
                }
            }
            .task {
                await vm.fetchAuthServices()
            }
        }
    }
}

#Preview {
    @Previewable @State var user: BillingUser? = .preview
    
    AuthAppsSection($user)
        .darkSchemePreferred()
        .environment(DashboardVM())
        .environment(OAuthVM())
}
