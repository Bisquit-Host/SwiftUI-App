import ScrechKit

struct DebugSettings: View {
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
        Section("Dev") {
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
}

#Preview {
    List {
        DebugSettings()
    }
    .environmentObject(ValueStore())
}
