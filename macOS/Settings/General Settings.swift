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
                Toggle("Game Center", isOn: $store.enableGameCenter)
                
                LaunchAtLogin.Toggle()
            }
            
            Section {
                Button("Log out") {
                    main {
                        store.isApiKeyValid = false
                        Keychain.delete(key: "selectedApiKey")
                    }
                }
            }
#if DEBUG
            Section("Debug") {
                HStack {
                    Text("Clear navigation path")
                    
                    Spacer()
                    
                    Button("Click") {
                        nav.clearNavCache()
                    }
                }
                
                Button("Restart app") {
                    restartApp()
                }
            }
#endif
        }
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
    GeneralSettings()
        .environment(NavModel.shared)
}
