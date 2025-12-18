import SwiftUI

struct BillingSettingsSecurity: View {
    @State private var `2FAVM` = Billing2FAVM()
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    @State private var showPasswordSheet = false
    @State private var show2FASheet = false
    @State private var confirmDisable2FA = false
    @State private var isDisabling2FA = false
    
    var body: some View {
        BillingSectionCard("Security") {
            BillingSecurityRow("2FA", icon: "shield.fill", enabled: user.twoFa, enabledText: "Disable", disabledText: "Connect") {
                confirmDisable2FA = true
            } onDisabledTap: {
                show2FASheet = true
            }
            
            BillingSecurityRow("Password", icon: "key.fill", enabled: user.hasPassword, enabledText: "Change", disabledText: "Set") {
                showPasswordSheet = true
            } onDisabledTap: {
                showPasswordSheet = true
            }
            
            GlassyNavLink("Passkeys", subtitle: "Passwordless sign in", icon: "person.badge.key.fill", tint: .blue) {
                PasskeyList()
            }
        }
        .alert("Disable 2FA?", isPresented: $confirmDisable2FA) {
            Button("Disable", role: .destructive, action: disable2FA)
                .disabled(isDisabling2FA)
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will remove extra protection for your account")
        }
        .sheet($showPasswordSheet) {
            NavigationStack {
                BillingPasswordSheet(hasPassword: user.hasPassword) {
                    await dashboardVM.fetchUserInfo()
                }
            }
        }
        .sheet($show2FASheet) {
            NavigationStack {
                Billing2FASetup {
                    await dashboardVM.fetchUserInfo()
                }
                .environment(`2FAVM`)
            }
        }
    }
    
    private func disable2FA() {
        guard !isDisabling2FA else { return }
        isDisabling2FA = true
        
        Task {
            let success = await `2FAVM`.disable()
            isDisabling2FA = false
            
            if success {
                await dashboardVM.fetchUserInfo()
            } else {
                confirmDisable2FA = true
            }
        }
    }
}

#Preview {
    BillingSettingsSecurity(.preview)
        .darkSchemePreferred()
}
