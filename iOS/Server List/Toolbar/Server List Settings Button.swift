import SwiftUI
import PteroNet
import SwiftData

struct ServerListSettingsButton: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Query(animation: .default) private var keys: [APIKey]
    
    @State private var sheetAccount = false
    
    var body: some View {
        @Bindable var vm = vm
        
        Menu {
            if keys.count > 0 {
                Button("Switch account", systemImage: "chevron.up.chevron.down") {
                    vm.sheetKeyStorage = true
                }
            }
            
            Button("Account", systemImage: "person.crop.circle") {
                sheetAccount = true
            }
            
            NavigationLink(destination: SettingsView()) {
                Label("Settings", systemImage: "gear")
            }
            
            Divider()
            
            Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                logout()
            }
        } label: {
            Image(systemName: "gear")
        }
        //        .onGamepadPressed(.menu) {
        //            sheetSettings = true
        //        }
        .sheet($sheetAccount) {
            AccountParent()
        }
    }
    
    private func logout() {
        navState.clear()
        store.isApiKeyValid = false
        Keychain.delete(key: "selectedApiKey")
    }
}

#Preview {
    List {
        ServerListSettingsButton()
    }
    .environment(NavState())
    .environment(ServerListVM())
    .environmentObject(ValueStore())
}
