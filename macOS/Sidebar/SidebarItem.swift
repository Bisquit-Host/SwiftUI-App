enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard",
         inbox = "Inbox",
         project = "Project",
         calendar = "Calendar",
         reports = "Reports",
         help = "Help & Center",
         settings = "Settings"
    
    var id: String {
        rawValue
    }
    
    var icon: String {
        switch self {
        case .dashboard: "rectangle.grid.2x2"
        case .inbox: "tray"
        case .project: "folder"
        case .calendar: "calendar"
        case .reports: "chart.bar"
        case .help: "questionmark.circle"
        case .settings: "gear"
        }
    }
}
