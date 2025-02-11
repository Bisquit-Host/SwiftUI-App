import ScrechKit
import Kingfisher
import PteroNet

struct Settings: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var sheetKeyStorage = false
    @State private var apiKey = Keychain.load(key: "selectedApiKey") ?? ""
    
    var body: some View {
        List {
            Button {
                sheetKeyStorage = true
            } label: {
                Label("API-keys", systemImage: "key.icloud.fill")
            }
            
            ListLink("API-key Creation") {
                Guide()
            }
            
            //                NavigationLink("Map") {
            //                    MapView()
            //                }
            
            ListLink("Configurations", icon: "externaldrive.badge.plus") {
                BrowserParent()
            }
            
            Section {
                Button(role: .destructive) {
                    main {
                        dismiss()
                        navState.path = NavigationPath()
                        store.isApiKeyValid = false
                        Keychain.delete(key: "selectedApiKey")
                    }
                } label: {
                    Text("\(Image(systemName: "rectangle.portrait.and.arrow.right")) Log out")
                }
            }
            
            DevSettings()
        }
        .navigationTitle("Settings")
        .listStyle(.grouped)
        .sheet($sheetKeyStorage) {
            CloudKeys($apiKey)
        }
    }
}

#Preview {
    Settings()
        .environmentObject(ValueStore())
}
