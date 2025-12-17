import SwiftUI

struct DebugSettingsSystemAlerts: View {
    var body: some View {
        Section("System alerts") {
            Button("Copied") {
                SystemAlert.copied()
            }
            
            Button("Network error") {
                SystemAlert.networkError()
            }
            
            Button("Restored backup") {
                SystemAlert.restored()
            }
            
            Button("Reinstalled server") {
                SystemAlert.reinstalled()
            }
            
            Button("Changes saved") {
                SystemAlert.changesSaved()
            }
            
            Button("Error (title & subtitle)") {
                SystemAlert.error("Title", subtitle: "Subtitle")
            }
        }
    }
}

#Preview {
    DebugSettingsSystemAlerts()
        .darkSchemePreferred()
}
