import ScrechKit
import PteroNet

struct AppSettings: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    private let bundle = Bundle.main
    private let device = WKInterfaceDevice.current()
    
    private var deviceAndName: String {
        "\(device.name) (\(device.systemName)\(device.systemVersion))"
    }
    
    private var appVersion: String {
        bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }
    
    private var appBuild: String {
        bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
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
    AppSettings()
        .environmentObject(ValueStore())
}
