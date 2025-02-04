import ScrechKit
import PteroNet

struct SettingsButton: View {
    @Environment(ServerListVM.self) private var vm
    //    @Environment(NavState.self) private var navState
    
    @State private var sheetAccount = false
    @State private var sheetSettings = false
    
    var body: some View {
        @Bindable var vm = vm
        
        Menu {
            MenuButton("Account", icon: "person.crop.circle") {
                sheetAccount = true
            }
#warning("iMessage: Settings and API-keys")
            //            MenuButton("API-keys", icon: "key") {
            //                vm.sheetKeyStorage = true
            //            }
            //
            //            MenuButton("Settings", icon: "gear") {
            //                sheetSettings = true
            //            }
            
            Divider()
            
            //            MenuButton("Log out", role: .destructive, icon: "rectangle.portrait.and.arrow.right") {
            //                main {
            //                    navState.path = NavigationPath()
            //                    store.isApiKeyValid = false
            //                    Keychain.delete(key: "selectedApiKey")
            //                }
            //            }
        } label: {
            Image(systemName: "person.crop.circle")
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
}
