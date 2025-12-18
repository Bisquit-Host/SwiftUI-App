import SwiftUI
import SwiftData
import PteroNet

struct AccountSettings: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    @Query(animation: .default) private var keys: [APIKey]
    
    @State private var sheetKeyStorage = false
    
    var body: some View {
        @Bindable var vm = vm
        
        BillingSectionCard("Account") {
            if keys.count > 0 {
                Button("Switch account", systemImage: "chevron.up.chevron.down") {
                    sheetKeyStorage = true
                }
                .sheet($sheetKeyStorage) {
                    CloudKeysParent($vm.apiKey) {
                        Task {
                            await vm.fetchServers(store.adminServerList)
                        }
                    }
                }
            }
            
            GlassyActionCard("Log out", icon: "rectangle.portrait.and.arrow.right", tint: .red, role: .destructive, action: logout)
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
