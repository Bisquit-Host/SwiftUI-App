import ScrechKit
import LaunchAtLogin
import PteroNet

struct AppSettings: View {
    @Environment(NavModel.self) private var nav
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
            Section("Debug") {
                Toggle("Dev mode", systemImage: "hammer", isOn: $store.devMode)
                
                Button("Clear navigation path") {
                    nav.clearNavCache()
                }
                
                Button("Restart app") {
                    restartApp()
                }
                
                NavigationLink("Gamepad test") {
                    GamepadDebug()
                        .frame(width: 500, height: 600)
                }
            }
#endif
        }
        .navigationTitle("Settings")
        .formStyle(.grouped)
        .buttonStyle(.plain)
        .frame(width: 500, height: 600)
    }
    
    private func restartApp() {
        let bundlePath = Bundle.main.bundlePath
        
        let command = """
        sleep 0.1; open "\(bundlePath)"
        """
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = ["-c", command]
        
        do {
            try task.run()
        } catch {
            print("Error restarting app:", error)
        }
        
        exit(0)
    }
}

#Preview {
    AppSettings()
        .environment(NavModel.shared)
}
