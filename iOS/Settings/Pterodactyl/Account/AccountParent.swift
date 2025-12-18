import SwiftUI

struct AccountParent: View {
    @State private var vm = AccountVM()
    @State private var apiKeyVM = ApikeyVM()
    @State private var sshVM = SSHVM()
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        TabView(selection: $store.selectedAccountTab) {
            Tab("Account", systemImage: "person.circle", value: 0) {
                NavigationStack {
                    PterSettings2FA()
                }
                .environment(vm)
            }
            
            Tab("API-keys", systemImage: "key.2.on.ring", value: 1) {
                NavigationStack {
                    ApikeyList()
                }
                .environment(apiKeyVM)
            }
            
            Tab("SSH-keys", systemImage: "key.2.on.ring", value: 2) {
                NavigationStack {
                    SSHList()
                }
                .environment(sshVM)
            }
        }
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
    AccountParent()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
