import SwiftUI

struct BillingAuthAppsSection: View {
    @Binding var user: BillingUser?
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @Environment(BillingOAuthVM.self) private var oauthVM
    
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
                
                BillingAuthAppRow("Google", icon: "globe", enabled: false)
                BillingAuthAppRow("Yandex", icon: "globe", enabled: false)
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
