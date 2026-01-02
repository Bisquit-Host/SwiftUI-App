import SwiftUI

struct DebugSettingsDeviceAndSystem: View {
    private var deviceAndSystem: String {
        "\(modelIdentifier) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))"
    }
    
    var body: some View {
        LabeledContent("Device and system", value: deviceAndSystem)
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
