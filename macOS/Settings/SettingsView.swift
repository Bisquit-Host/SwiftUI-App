import ScrechKit
import LaunchAtLogin

struct SettingsView: View {
    var body: some View {
        Form {
            Section {
                LaunchAtLogin.Toggle()
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
}
