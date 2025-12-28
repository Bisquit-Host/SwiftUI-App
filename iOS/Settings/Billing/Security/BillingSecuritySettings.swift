import SwiftUI

struct BillingSecuritySettings: View {
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    var body: some View {
        BillingSectionCard("Security") {
            SecuritySettings2FAButton(user.twoFa)
            SecuritySettingsPasswordButton(user.hasPassword)
            SecuritySettingsPasskeysButton()
        }
    }
}

#Preview {
    BillingSecuritySettings(.preview)
        .darkSchemePreferred()
        .environment(BillingDashboardVM())
}
