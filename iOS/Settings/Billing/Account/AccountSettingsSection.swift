import SwiftUI
import PteroNet

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
                AccountSettingsChangeLogin(user)
                
                GlassyButton("Language", subtitle: user.lang.uppercased(), icon: "character.cursor.ibeam", tint: .indigo)
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
            try await Task.sleep(for: .seconds(0.5))
            let token = accessToken()
            
#if os(iOS)
            if let token {
                let _ = await billingLogoutAPI(accessToken: token)
            }
#endif
#if os(iOS)
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
        .environment(DashboardViewVM())
}
