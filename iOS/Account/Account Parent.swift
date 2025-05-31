import SwiftUI

struct AccountParent: View {
    @State private var vm = AccountVM()
    @State private var apiKeysVM = ApikeyVM()
    @State private var sshVM = SSHVM()
    
    @AppStorage("acc_selected_tab") private var accountSelectedTab = 0
    
    @State private var sheetApiKeys = false
    
    var body: some View {
        TabView(selection: $accountSelectedTab) {
            NavigationView {
                AccountView()
            }
            .environment(vm)
            .tag(0)
            .tabItem {
                Label("Account", systemImage: "person.circle")
            }
            
            NavigationView {
                ApikeyList()
            }
            .environment(apiKeysVM)
            .tag(1)
            .tabItem {
                Label("API-keys", systemImage: "key.2.on.ring")
            }
            
            NavigationView {
                SSHList()
            }
            .environment(sshVM)
            .tag(2)
            .tabItem {
                Label("SSH-keys", systemImage: "key.2.on.ring")
            }
        }
        .task {
            if !System.lowPowerMode {
                await vm.fetch()
                await vm.twoFaDetails()
                sshVM.fetchKeys()
                
                await apiKeysVM.fetchKeys()
            }
        }
    }
}

#Preview {
    AccountParent()
}
