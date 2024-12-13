import ScrechKit
import PteroNet

struct SettingsButton: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: ValueStorage
    
    @State private var sheetAccount = false
    @State private var sheetSettings = false
    
    var body: some View {
        @Bindable var vm = vm
        
        Menu {
            Section {
                TopbarGridButton()
            }
            
            MenuButton("API-keys", icon: "key") {
                vm.sheetKeyStorage = true
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
                    navState.path = NavigationPath()
                    settings.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                }
            }
        } label: {
            Image(systemName: "gear")
                .bold()
        }
        .sheet($sheetAccount) {
            AccountParent()
        }
        .sheet($sheetSettings) {
            SettingsParent()
        }
    }
}

#Preview {
    SettingsButton()
        .environment(ServerListVM())
        .environmentObject(ValueStorage())
}
