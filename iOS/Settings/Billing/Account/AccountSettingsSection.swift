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
            
            if !Keychain.delete(key: "access_token") {
                Logger().error("Error logging out")
            }
            
            store.accessTokenExpiresIn = 0
            store.accessToken = nil
            store.lastBillingTokenRefresh = nil
            Keychain.delete(key: "refresh_token")
            
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
