import SwiftUI

struct BillingAuthAppsSection: View {
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @Environment(BillingOAuthVM.self) private var oauthVM
    
    @Binding var user: BillingUser?
    
    var body: some View {
        if let user {
            BillingSectionCard("Auth apps") {
                BillingAuthAppRow("GitHub", icon: "app.connected.to.app.below.fill", enabled: !(user.githubId ?? "").isEmpty, isLoading: oauthVM.isLinkingGitHub) {
                    oauthVM.startGitHubLinking {
                        Task {
                            await dashboardVM.fetchUserInfo()
                        }
                    }
                } onDisconnect: {
                    await oauthVM.disconnectGithub {
                        await dashboardVM.fetchUserInfo()
                    }
                }
                
                BillingAuthAppRow("Google", icon: "globe", enabled: !(user.googleId ?? "").isEmpty, isLoading: oauthVM.isLinkingGoogle) {
                    oauthVM.startGoogleLinking {
                        Task {
                            await dashboardVM.fetchUserInfo()
                        }
                    }
                } onDisconnect: {
                    await oauthVM.disconnectGoogle {
                        await dashboardVM.fetchUserInfo()
                    }
                }
                
                BillingAuthAppRow("Yandex", icon: "globe", enabled: !(user.yandexId ?? "").isEmpty, isLoading: oauthVM.isLinkingYandex) {
                    oauthVM.startYandexLinking {
                        Task {
                            await dashboardVM.fetchUserInfo()
                        }
                    }
                } onDisconnect: {
                    await oauthVM.disconnectYandex {
                        await dashboardVM.fetchUserInfo()
                    }
                }
            }
        }
    }
}

#Preview {
    BillingAuthAppsSection(user: .constant(.preview))
        .darkSchemePreferred()
        .environment(BillingDashboardVM())
        .environment(BillingOAuthVM())
}
