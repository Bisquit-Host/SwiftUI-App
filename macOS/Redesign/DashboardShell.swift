import ScrechKit
import PteroNet

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
            DashboardSidebar(selection: $selection)
        } detail: {
            switch selection {
            case .dashboard, .none: DashboardView()
            case .inbox:            Placeholder(title: "Inbox")
            case .project:          Placeholder(title: "Project")
            case .calendar:         Placeholder(title: "Calendar")
            case .reports:          Placeholder(title: "Reports")
            case .help:             Placeholder(title: "Help & Center")
            case .settings:         Placeholder(title: "Settings")
            }
        }
    }
}

#Preview {
    DashboardShell()
        .darkSchemePreferred()
}
