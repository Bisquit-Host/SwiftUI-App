import ScrechKit

struct DevSettings: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    private let device = UIDevice.current
    private let bundle = Bundle.main
    
    private var appVersion: String {
        bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }
    
    private var appBuild: String {
        bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    }
    
    private var parameters: [(String, String)] {
        var params = [
            ("App version", "\(appVersion) (\(appBuild))"),
            ("Device and system", "\(device.modelIdentifier) (\(device.systemName) \(device.systemVersion))")
        ]
        
        return params
    }
    
    var body: some View {
        Section("Admin") {
            ForEach(parameters, id: \.0) { parameter in
                ListParameter(parameter.0, parameter: parameter.1)
            }
            
            Toggle("Admin mode", isOn: $settings.adminMode)
            
            //#if !os(tvOS)
            //            ColorPicker("Background color (disabled)", selection: $settings.backgroundColor)
            //#endif
        }
#if !os(tvOS)
        .listRowBackground(settings.transparentList ? .clear : Color.list)
#endif
    }
}

public extension UIDevice {
    var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
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
    .environmentObject(SettingsStorage())
}
