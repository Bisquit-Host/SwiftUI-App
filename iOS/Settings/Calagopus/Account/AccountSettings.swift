import SwiftUI

struct AccountSettings: View {
    @State private var vm = AccountVM()
    @State private var sshVM = SSHVM()
    
    var body: some View {
        BillingSectionCard("Account") {
            CredentialsButton()
            
            GlassyNavLink("SSH-keys", icon: "key.2.on.ring.fill", tint: .blue) {
                SSHList()
                    .environment(sshVM)
            }
            
            PterSettings2FA()
            AccoutSettingsLogoutButton()
        }
        .environment(vm)
        .task {
            if !System.lowPowerMode {
                async let fetch: () = vm.fetch()
                async let twoFa: () = vm.twoFaDetails()
                async let ssh: () = sshVM.fetchKeys()
                
                _ = await (fetch, twoFa, ssh)
            }
        }
    }
}

#Preview {
    AccountSettings()
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
