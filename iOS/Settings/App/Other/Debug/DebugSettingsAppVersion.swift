import SwiftUI

struct DebugSettingsAppVersion: View {
    private var version: String {
        let version = Bundle.version ?? "N/A"
        let build = Bundle.build ?? "N/A"
        
        return "v\(version) (B\(build))"
    }
    
    var body: some View {
        LabeledContent("App version", value: version)
    }
}
