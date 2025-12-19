import SwiftUI

struct DebugSettingsSystemAlerts: View {
    var body: some View {
        Section {
            Menu {
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
            } label: {
                Label("Present system alert", systemImage: "bubble")
            }
        }
    }
}

#Preview {
    DebugSettingsSystemAlerts()
        .darkSchemePreferred()
}
