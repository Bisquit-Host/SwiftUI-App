import SwiftUI

// MARK: 1
// Backups
// DB's
// Sudomains
// Schedules
// Users
// Allocations

// MARK: 2
// Console
// Files
// Location

// MARK: 3
// Logs

// MARK: Toolbar
// Setup
// Settings

struct DashboardShell: View {
    @State private var selection: SidebarItem? = .dashboard
    
    var body: some View {
        NavigationSplitView {
            DashboardSidebar($selection)
        } detail: {
            Text("Select a server")
        }
    }
}

#Preview {
    DashboardShell()
        .darkSchemePreferred()
}
