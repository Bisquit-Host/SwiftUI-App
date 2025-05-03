import ScrechKit
import LaunchAtLogin
import PteroNet

struct GeneralSettings: View {
    @Environment(NavModel.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Navigation mode")
                    
                    Spacer()
                    
                    NavModeButton()
                }
            }
            
            Section {
                LaunchAtLogin.Toggle()
            }
            
            Section {
                Button("Log out") {
                    main {
                        // nav.clear()
                        store.isApiKeyValid = false
                        Keychain.delete(key: "selectedApiKey")
                    }
                }
            }
            
            Section {
#if DEBUG
                HStack {
                    Text("Clear navigation path")
                    
                    Spacer()
                    
                    Button("Click") {
                        nav.clearNavCache()
                    }
                }
#endif
            } header: {
                Text("Debug")
                    .headline()
            }
        }
    }
}

#Preview {
    GeneralSettings()
        .environment(NavModel.shared)
}
