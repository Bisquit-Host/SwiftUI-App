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
        
        let script = """
        #!/bin/bash
        sleep 0.1
        open "\(bundlePath)"
        """
        
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("sh")
        
        do {
            try script.write(
                to: tempURL,
                atomically: true,
                encoding: .utf8
            )
            
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o755],
                ofItemAtPath: tempURL.path
            )
            
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/bin/bash")
            task.arguments = [tempURL.path]
            
            try task.run()
        } catch {
            print("Error creating restart script:", error)
        }
        
        exit(0)
    }
}

#Preview {
    GeneralSettings()
        .environment(NavModel.shared)
}
