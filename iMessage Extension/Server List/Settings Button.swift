import SwiftUI
import PteroNet

struct SettingsButton: View {
    @Environment(ServerListVM.self) private var vm
    //    @Environment(NavState.self) private var nav
    
    @State private var sheetAccount = false
    @State private var sheetSettings = false
    
    var body: some View {
        @Bindable var vm = vm
        
        Menu {
            Button("Account", systemImage: "person.crop.circle") {
                sheetAccount = true
            }
#warning("iMessage: Settings and API-keys")
            //            Button("API-keys", systemImage: "key") {
            //                sheetKeyStorage = true
            //            }
            //
            //            Button("Settings", systemImage: "gear") {
            //                sheetSettings = true
            //            }
            
            Divider()
            
            //            Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
            //                main {
            //                    nav.clear()
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
            NavigationStack {
                SettingsView()
            }
        }
    }
}

#Preview {
    SettingsButton()
        .environment(ServerListVM())
}
