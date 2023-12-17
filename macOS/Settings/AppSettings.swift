import ScrechKit
import PteroNet

struct AppSettings: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        VStack {
            Text("Settings")
            
            Button("Reset") {
                main {
                    navState.path = NavigationPath()
                    settings.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                }
            }
        }
        .padding()
    }
}

#Preview {
    AppSettings()
}
