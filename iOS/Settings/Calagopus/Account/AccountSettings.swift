import SwiftUI

struct AccountSettings: View {
    @State private var apiKeyVM = CalagopusAPIKeyVM()
    @State private var sshVM = SSHVM()
    
    var body: some View {
        BillingSectionCard("Account") {
            GlassyNavLink("API keys", icon: "key.2.on.ring.fill", tint: .blue) {
                CalagopusAPIKeyListView()
                    .environment(apiKeyVM)
            }
            
            GlassyNavLink("SSH-keys", icon: "key.2.on.ring.fill", tint: .blue) {
                SSHList()
                    .environment(sshVM)
            }
        }
        .task {
            if !System.lowPowerMode {
                async let ssh: () = sshVM.fetchKeys()
                async let api: () = apiKeyVM.fetchKeys()
                
                _ = await (ssh, api)
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
