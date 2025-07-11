import ScrechKit

struct DevSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    private let device = UIDevice.current
    
    private var appVersion: String {
        Bundle.version ?? "N/A"
    }
    
    private var appBuild: String {
        Bundle.build ?? "N/A"
    }
    
    private var version: String {
        "v\(appVersion) (B\(appBuild))"
    }
    
    private var deviceAndSystem: String {
        "\(device.modelIdentifier) (\(device.systemName) \(device.systemVersion))"
    }
    
    var body: some View {
        Section {
            ListParam("App version", param: version)
            
            ListParam("Device and system", param: deviceAndSystem)
#if !os(tvOS)
            NavigationLink("Debug") {
                DebugSettings()
            }
#endif
        } header: {
            Text("Dev")
        } footer: {
            ServerListFooter()
        }
    }
}

fileprivate extension UIDevice {
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
