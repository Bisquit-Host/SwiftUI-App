import ScrechKit

struct DevSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    private let device = UIDevice.current
    private let bundle = Bundle.main
    
    private var appVersion: String {
        bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }
    
    private var appBuild: String {
        bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    }
    
    private var version: String {
        "\(appVersion) (B\(appBuild))"
    }
    
    private var deviceAndSystem: String {
        "\(device.modelIdentifier) (\(device.systemName) \(device.systemVersion))"
    }
    
    var body: some View {
        Section("Dev") {
            ListParam("App version", param: version)
            
            ListParam("Device and system", param: deviceAndSystem)
            
            Toggle("Developer mode", isOn: $store.devMode)
#if !os(tvOS)
            NavigationLink("Debug") {
                DebugSettings()
            }
#endif
            ServerListFooter()
        }
#if !os(tvOS)
        .listRowBackground(store.transparentList ? .clear : Color.list)
#endif
    }
}

public extension UIDevice {
    var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        return machineMirror.children.reduce("") { identifier, element in
            guard
                let value = element.value as? Int8,
                value != 0
            else {
                return identifier
            }
            
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
}

#Preview {
    List {
        DevSettings()
    }
    .environmentObject(ValueStore())
}
