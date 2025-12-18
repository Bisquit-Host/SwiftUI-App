import SwiftUI
import PteroNet

struct AccountSettings: View {
    @State private var vm = AccountVM()
    @State private var apiKeyVM = ApikeyVM()
    @State private var sshVM = SSHVM()
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        BillingSectionCard("Account") {
            // "Account", systemImage: "person.circle"
            NavigationStack {
                PterSettings2FA()
            }
            .environment(vm)
            
            CredentialsButton()
            AccountSettingsCredentials()
            
            GlassyNavLink("API-keys", icon: "key.2.on.ring.fill", tint: .blue) {
                ApikeyList()
                    .environment(apiKeyVM)
            }
            
            GlassyNavLink("SSH-keys", icon: "key.2.on.ring.fill", tint: .blue) {
                SSHList()
                    .environment(sshVM)
            }
            
            AccountSettingsSwitchAccountButton()
            GlassyActionCard("Log out", icon: "rectangle.portrait.and.arrow.right", tint: .red, role: .destructive, action: logout)
        }
        .environment(vm)
        .task {
            if !System.lowPowerMode {
                async let fetch: () = vm.fetch()
                async let twoFa: () = vm.twoFaDetails()
                async let ssh: () = sshVM.fetchKeys()
                async let api: () = apiKeyVM.fetchKeys()
                
                _ = await (fetch, twoFa, ssh, api)
            }
        }
    }
    
    private func logout() {
        nav.clear()
        store.isApiKeyValid = false
        Keychain.delete(key: "selectedApiKey")
    }
}

#Preview {
    AccountSettings()
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
