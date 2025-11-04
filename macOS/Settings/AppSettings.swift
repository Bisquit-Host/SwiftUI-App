import ScrechKit
import LaunchAtLogin
import PteroNet

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Label("Navigation mode", systemImage: "safari")
                    
                    Spacer()
                    
                    NavModeButton()
                }
                
                Toggle("Game Center", systemImage: "gamecontroller", isOn: $store.enableGameCenter)
                
                LaunchAtLogin.Toggle()
            }
            
            Section {
                Button("Log out", systemImage: "rectangle.portrait.and.arrow.right") {
                    store.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                }
            }
#if DEBUG
            DebugSettings()
#endif
        }
        .navigationTitle("Settings")
        .formStyle(.grouped)
        .buttonStyle(.plain)
        .frame(width: 500, height: 600)
    }
}

#Preview {
    AppSettings()
        .darkSchemePreferred()
        .environment(NavModel.shared)
        .environmentObject(ValueStore())
}
