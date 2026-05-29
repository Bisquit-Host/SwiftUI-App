import SwiftUI

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    private var deviceAndName: String {
        let device = WKInterfaceDevice.current()
        
        return"\(device.name) (\(device.systemName)\(device.systemVersion))"
    }
    
    private var version: String {
        let version = Bundle.version ?? "N/A"
        let build = Bundle.build ?? "N/A"
        
        return "\(version) (B\(build))"
    }
    
    var body: some View {
        Section("Dev") {
            LabeledContent("App version", value: version)
            
            VStack(alignment: .leading) {
                Text("Device and system")
                
                Text(deviceAndName)
                    .secondary()
                    .footnote()
            }
            
            Toggle("Dev mode", isOn: $store.devMode)
        }
    }
}

#Preview {
    List {
        DebugSettings()
    }
    .environmentObject(ValueStore())
}
