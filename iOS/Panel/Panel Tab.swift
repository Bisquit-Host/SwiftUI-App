import SwiftUI

enum PanelTab: String, CaseIterable, Identifiable, Codable {
    case info,
         console,
         files,
         backups,
         settings,
         other,
         startup,
         users,
         schedules,
         databases,
         allocations,
         logs,
         admin,
         subdomains
    
    var id: String {
        rawValue
    }
    
    var title: LocalizedStringKey {
        switch self {
        case .info: "Info"
        case .console: "Console"
        case .files: "Files"
        case .backups: "Backups"
        case .settings: "Settings"
        case .other: "Other"
        case .startup: "Startup"
        case .users: "Users"
        case .schedules: "Schedules"
        case .databases: "Databases"
        case .allocations: "Allocations"
        case .logs: "Logs"
        case .admin: "Admin"
        case .subdomains: "Subdomains"
        }
    }
}
