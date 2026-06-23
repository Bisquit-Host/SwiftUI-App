import SwiftUI
import Calagopus

/// TODO
// Console
// Setup
// Settings
// Location

struct DashboardShell: View {
    var body: some View {
        NavigationSplitView {
            DashboardSidebar()
                .navigationDestination(for: ServerAttributes.self) {
                    DashboardView($0)
                        .id($0.id)
                }
        } detail: {
            Text("Select a server")
        }
    }
}

#Preview {
    DashboardShell()
        .darkSchemePreferred()
}
