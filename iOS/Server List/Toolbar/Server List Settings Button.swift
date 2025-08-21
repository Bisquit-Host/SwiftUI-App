import ScrechKit
import PteroNet
import SwiftData

struct ServerListSettingsButton: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Query(animation: .default) private var keys: [APIKey]
    
    @State private var sheetAccount = false
    @State private var sheetSettings = false
    
    var body: some View {
        @Bindable var vm = vm
        
        Menu {
            if keys.count > 0 {
                MenuButton("Switch account", icon: "chevron.up.chevron.down") {
                    vm.sheetKeyStorage = true
                }
            }
            
            MenuButton("Account", icon: "person.crop.circle") {
                sheetAccount = true
            }
            
            MenuButton("Settings", icon: "gear") {
                sheetSettings = true
            }
            
            Divider()
            
            MenuButton("Log out", role: .destructive, icon: "rectangle.portrait.and.arrow.right") {
                main {
                    navState.clear()
                    store.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                }
            }
        } label: {
            Image(systemName: "gear")
        }
        .onGamepadPressed(.menu) {
            sheetSettings = true
        }
        .sheet($sheetAccount) {
            AccountParent()
        }
        .sheet($sheetSettings) {
            NavigationStack {
                SettingsView()
            }
        }
    }
}

#Preview {
    List {
        ServerListSettingsButton()
    }
    .darkSchemePreferred()
    .environment(NavState())
    .environment(ServerListVM())
    .environmentObject(ValueStore())
}
