import ScrechKit
import LaunchAtLogin
import Calagopus

struct SettingsView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Form {
            Section {
                LaunchAtLogin.Toggle()
            }
            
            Section {
                Button("Log out", systemImage: "rectangle.portrait.and.arrow.right") {
                    store.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                    UserDefaults.standard.removeObject(forKey: "servers")
                }
                .foregroundStyle(.red)
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
    SettingsView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
