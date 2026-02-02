import SwiftUI

struct DebugSettingsSection: View {
    private let device = UIDevice.current
    
    private var version: String {
        let version = Bundle.version ?? "N/A"
        let build = Bundle.build ?? "N/A"
        
        return "v\(version) (B\(build))"
    }
    
    private var deviceAndSystem: String {
        "\(modelIdentifier) (\(device.systemName) \(device.systemVersion))"
    }
    
    var body: some View {
        Section {
            LabeledContent("App version", value: version)
            LabeledContent("Device and system", value: deviceAndSystem)
        } header: {
            Text("Dev")
        } footer: {
            DebugSettingsFooter()
        }
    }
    
    private var modelIdentifier: String {
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
        DebugSettingsSection()
    }
    .darkSchemePreferred()
}
