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
                .navigationDestination(for: String.self) {
                    DashboardView($0)
                        .id($0)
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
