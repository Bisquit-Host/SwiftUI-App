import ScrechKit
import PteroNet
import LaunchAtLogin

struct AppSettings: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: ValueStorage
    
    var body: some View {
        VStack {
            Button("Reset") {
                main {
                    navState.path = NavigationPath()
                    settings.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                }
            }
            
            LaunchAtLogin.Toggle()
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}

#Preview {
    AppSettings()
}
