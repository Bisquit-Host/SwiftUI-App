import ScrechKit
import PteroNet

struct AppSettings: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    private let device = WKInterfaceDevice.current()
    
    private var deviceAndName: String {
        "\(device.name) (\(device.systemName)\(device.systemVersion))"
    }
    
    private var appVersion: String {
        Bundle.version ?? "N/A"
    }
    
    private var appBuild: String {
        Bundle.build ?? "N/A"
    }
    
    private var version: String {
        "\(appVersion) (B\(appBuild))"
    }
    
    var body: some View {
        List {
            Section("General") {
                Button("Log out", role: .destructive) {
                    main {
                        navState.clear()
                        store.isApiKeyValid = false
                        Keychain.delete(key: "selectedApiKey")
                    }
                }
            }
            
            Section("Dev") {
                NavigationLink("Map") {
                    MapView()
                }
                
                ListParam("App version", param: version)
                
                VStack(alignment: .leading) {
                    Text("Device and system")
                    
                    Text(deviceAndName)
                        .secondary()
                        .footnote()
                }
                
                Toggle("Developer mode", isOn: $store.devMode)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        AppSettings()
    }
    .environment(NavState())
    .environmentObject(ValueStore())
}
