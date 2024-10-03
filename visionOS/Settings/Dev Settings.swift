import ScrechKit

//struct DevSettings: View {
//    @EnvironmentObject private var settings: SettingsStorage
//
//    private let device = UIDevice.current
//    private let bundle = Bundle.main
//    private let bounds = UIScreen.main.bounds
//
//    private var appVersion: String {
//        bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
//    }
//
//    private var appBuild: String {
//        bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
//    }
//
//    private var parameters: [(String, String)] {
//        var params = [
//            ("App version", "\(appVersion) (\(appBuild))"),
//            ("Device and system", "\(device.modelIdentifier) (\(device.systemName) \(device.systemVersion))")
//        ]
//
//#if !os(tvOS)
//        params.append(("Battery", "\(Int(device.batteryLevel * -100))%"))
//#endif
//
//        return params
//    }
//
//    var body: some View {
//        Section("Developer (Beta)") {
//            ForEach(parameters, id: \.0) { parameter in
//                ListParam(parameter.0, param: parameter.1)
//            }
//
//            Toggle("Admin mode", isOn: $settings.adminMode)
//
//            Toggle("BisquitFall", isOn: $settings.enableBisquitFall)
//
//#if !os(tvOS)
//            ColorPicker("Background color (disabled)", selection: $settings.backgroundColor)
//#endif
//        }
//        .listRowBackground(settings.transparentList ? .clear : Color.list)
//    }
//}

//public extension UIDevice {
//    var modelIdentifier: String {
//        var systemInfo = utsname()
//        uname(&systemInfo)
//
//        let machineMirror = Mirror(reflecting: systemInfo.machine)
//
//        return machineMirror.children.reduce("") { identifier, element in
//guard let value = element.value as? Int8, value != 0 else {
//    return identifier
//}
//            return identifier + String(UnicodeScalar(UInt8(value)))
//        }
//    }
//}

struct DevSettings: View {
    var body: some View {
        VStack {
            
        }
    }
}

#Preview {
    DevSettings()
        .padding()
        .glassBackgroundEffect()
}
