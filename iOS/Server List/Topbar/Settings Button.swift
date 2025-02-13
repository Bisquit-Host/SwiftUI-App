import ScrechKit
import PteroNet

struct SettingsButton: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetAccount = false
    @State private var sheetSettings = false
    
    var body: some View {
        @Bindable var vm = vm
        
        Menu {
            Section {
                TopbarGridButton()
            }
            
            MenuButton("Switch Account", icon: "arrow.trianglehead.2.clockwise.rotate.90") {
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
                    navState.clear()
                    store.isApiKeyValid = false
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
        .environmentObject(ValueStore())
}
