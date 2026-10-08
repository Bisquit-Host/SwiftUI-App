import SwiftUI
import Calagopus
import BisquitoNet

struct AccountSettingsSection: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
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
            
            let animation: Animation? = store.bigAssAnimations && !reduceMotion ? .smooth(duration: 0.35) : nil
            
            withAnimation(animation) {
                store.accessToken = nil
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
