import SwiftUI

enum PanelTab: String, CaseIterable, Identifiable, Codable {
    case info, console, files,
         backups, settings, startup,
         users, schedules, databases,
         allocations, logs, subdomains
    
    var id: String { rawValue }
    
    var name: LocalizedStringKey {
        switch self {
        case .info:        "Info"
        case .console:     "Console"
        case .files:       "Files"
        case .backups:     "Backups"
        case .settings:    "Settings"
        case .startup:     "Startup"
        case .users:       "Users"
        case .schedules:   "Schedules"
        case .databases:   "Databases"
        case .allocations: "Ports"
        case .logs:        "Logs"
        case .subdomains:  "Subdomains"
        }
    }
}
