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
                Label("API-keys", systemImage: "hammer")
            }
            
            NavigationView {
                SSHList()
            }
            .environment(sshVM)
            .tag(2)
            .tabItem {
                Label("SSH-keys", systemImage: "hammer")
            }
        }
        .task {
            if !System.lowPowerMode {
                vm.fetch()
                vm.twoFaDetails()
                apiKeysVM.fetchKeys()
                sshVM.fetchKeys()
            }
        }
    }
}

#Preview {
    AccountParent()
}
