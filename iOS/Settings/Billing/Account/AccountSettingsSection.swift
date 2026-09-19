import SwiftUI
import Calagopus
import BisquitoNet

struct AccountSettingsSection: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    
    private let user: BillingUser?
    
    init(_ user: BillingUser?) {
        self.user = user
    }
    
    var body: some View {
        BillingSectionCard("Account") {
            if let user {
                AccountSettingsHeader(user)
                
                Divider()
                
                AccountSettingsChangeEmail(user)
                AccountSettingsRename(user)
                
                AccountSettingsLanguage(user)
                GlassyButton("Currency", subtitle: user.currency.rawValue, icon: user.currency.sfSymbol, tint: .yellow)
            }
            
            GlassyActionCard("Log out", icon: "rectangle.portrait.and.arrow.right", tint: .red, role: .destructive) {
                logout()
            }
        }
    }
    
    private func logout() {
        dismiss()
        
        Task {
            try? await Task.sleep(for: .seconds(0.5))
            let token = accessToken()
#if os(iOS)
            await logoutPanelSessionIfPossible()
            
            if let token {
                let _ = await billingLogoutAPI(accessToken: token)
            }
            
            await PushTokenService.invalidateIfPossible()
#endif
            if !deleteBillingSessionToken() {
                Logger().error("Error logging out")
            }
            
            store.accessToken = nil
            
            withAnimation {
                store.updateAccessToken()
            }
        }
    }
}

#Preview {
    AccountSettingsSection(.preview)
        .darkSchemePreferred()
        .environment(BillingSettingsVM())
        .environment(DashboardVM())
}
