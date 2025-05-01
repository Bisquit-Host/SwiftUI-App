import ScrechKit
import PteroNet
import SwiftData

struct SettingsButton: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Query(animation: .default) private var keys: [APIKey]
    
    @State private var sheetAccount = false
    @State private var sheetSettings = false
    
    var body: some View {
        @Bindable var vm = vm
        
        Menu {
            Section {
                TopbarGridButton()
            }
            
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
                .footnote(.bold)
                .frame(width: 35, height: 35)
                .background(.ultraThinMaterial, in: .circle)
        }
        .foregroundStyle(.foreground)
        .sheet($sheetAccount) {
            AccountParent()
        }
        .sheet($sheetSettings) {
            NavigationView {
                SettingsView()
            }
        }
    }
}

#Preview {
    SettingsButton()
        .environment(ServerListVM())
        .environmentObject(ValueStore())
}
