import ScrechKit
import PteroNet

struct AppSettings: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: SettingsStorage
    
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
    
    private var parameters: [(String, String)] {
        [
            ("App version", "\(appVersion) (\(appBuild))"),
            ("Device and system", deviceAndName)
        ]
    }
    
    var body: some View {
        List {
            Section("General") {
                Button("Log out", role: .destructive) {
                    main {
                        navState.path = NavigationPath()
                        settings.isApiKeyValid = false
                        Keychain.delete(key: "selectedApiKey")
                    }
                }
            }
            
            Section("Developer (Beta)") {
                NavigationLink("Map") {
                    MapView()
                }
                
                ForEach(parameters, id: \.0) { parameter in
                    ListParam(parameter.0, param: parameter.1)
                        .font(parameter.0 == "Device and system" ? .footnote : .none)
                }
                
                Toggle("Admin mode", isOn: $settings.adminMode)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    AppSettings()
        .environmentObject(SettingsStorage())
}
