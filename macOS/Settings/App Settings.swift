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
                
                Toggle(isOn: $store.enableGameCenter) {
                    Label("Game Center", systemImage: "gamecontroller.fill")
                }
                
                LaunchAtLogin.Toggle()
            }
            
            Section {
                Button {
                    main {
                        store.isApiKeyValid = false
                        Keychain.delete(key: "selectedApiKey")
                    }
                } label: {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
#if DEBUG
            Section("Debug") {
                Toggle("Dev mode", isOn: $store.devMode)
                
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
