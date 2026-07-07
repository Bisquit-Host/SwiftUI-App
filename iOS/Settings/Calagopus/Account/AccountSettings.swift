import SwiftUI

struct AccountSettings: View {
    @State private var vm = AccountVM()
    @State private var apiKeyVM = CalagopusAPIKeyVM()
    @State private var sshVM = SSHVM()
    
    var body: some View {
        BillingSectionCard("Account") {
            CredentialsButton()
            
            GlassyNavLink("API keys", icon: "key.2.on.ring.fill", tint: .blue) {
                CalagopusAPIKeyListView()
                    .environment(apiKeyVM)
            }
            
            GlassyNavLink("SSH-keys", icon: "key.2.on.ring.fill", tint: .blue) {
                SSHList()
                    .environment(sshVM)
            }
            
            Calagopus2FASettings()
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
}

#Preview {
    AccountSettings()
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
