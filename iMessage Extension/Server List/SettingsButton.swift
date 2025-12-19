import SwiftUI
import PteroNet

struct SettingsButton: View {
    @Environment(ServerListVM.self) private var vm
    //    @Environment(NavState.self) private var nav
    
    @State private var sheetSettings = false
    
    var body: some View {
        @Bindable var vm = vm
        
        Menu {
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
            //                nav.clear()
            //                store.isApiKeyValid = false
            //                Keychain.delete(key: "selectedApiKey")
            //            }
        } label: {
            Image(systemName: "person.crop.circle")
        }
        .sheet($sheetSettings) {
            NavigationStack {
                PterodactylSettings()
            }
        }
    }
}

#Preview {
    SettingsButton()
        .darkSchemePreferred()
        .environment(ServerListVM())
}
