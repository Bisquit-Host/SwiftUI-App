import SwiftUI
import OSLog

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Debug") {
            Toggle("Dev mode", systemImage: "hammer", isOn: $store.devMode)
            
            Button("Restart app", action: restartApp)
            
            DebugSettingsTips()
        }
    }
    
    private func restartApp() {
        let command = #"sleep 0.1; open "\(bundlePath)""#
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = ["-c", command]
        
        do {
            try task.run()
        } catch {
            Logger().error("Error restarting app: \(error)")
        }
        
        exit(0)
    }
}

#Preview {
    DebugSettings()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
