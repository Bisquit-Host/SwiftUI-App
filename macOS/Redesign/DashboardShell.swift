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
            switch selection {
            case .dashboard, .none: DashboardView()
            case .inbox:            Placeholder("Inbox")
            case .project:          Placeholder("Project")
            case .calendar:         Placeholder("Calendar")
            case .reports:          Placeholder("Reports")
            case .help:             Placeholder("Help & Center")
            case .settings:         Placeholder("Settings")
            }
        }
    }
}

#Preview {
    DashboardShell()
        .darkSchemePreferred()
}
