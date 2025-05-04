enum PanelTab: String, CaseIterable, Identifiable, Codable {
    case info = "Info",
         console = "Console",
         files = "Files",
         backups = "Backups",
         settings = "Settings",
         other = "Other",
         startup = "Startup",
         users = "Users",
         schedules = "Schedules",
         databases = "Databases",
         allocations = "Allocations",
         logs = "Logs",
         admin = "Admin",
         subdomains = "Subdomains"
    
    var id: String {
        rawValue
    }
}
