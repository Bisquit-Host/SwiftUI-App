import SwiftUI

struct AccountParent: View {
    @State private var vm = AccountVM()
    @State private var apiKeyVM = ApikeyVM()
    @State private var sshVM = SSHVM()
    
    @AppStorage("acc_selected_tab") private var accountSelectedTab = 0
    
    @State private var sheetApiKeys = false
    
    var body: some View {
        TabView(selection: $accountSelectedTab) {
            Tab("Account", systemImage: "person.circle", value: 0) {
                NavigationView {
                    AccountView()
                }
                .environment(vm)
            }
            
            Tab("API-keys", systemImage: "key.2.on.ring", value: 1) {
                NavigationView {
                    ApikeyList()
                }
                .environment(apiKeyVM)
            }
            
            Tab("SSH-keys", systemImage: "key.2.on.ring", value: 2) {
                NavigationView {
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
}
