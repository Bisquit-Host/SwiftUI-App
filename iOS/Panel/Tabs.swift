import SwiftUI

enum Tabs: String, CaseIterable, Identifiable, Codable {
    case info = "info.circle",
         allocations = "link",
         users = "person.2",
         logs = "list.bullet.rectangle",
         subdomains = "globe",
         console = "terminal",
         files = "folder",
         backup = "externaldrive.badge.icloud",
         schedules = "calendar.badge.clock",
         databases = "externaldrive.fill.badge.person.crop",
         settings = "gearshape",
         startup = "play.circle",
         versionChanger = "arrow.clockwise.circle",
         modInstaller = "shippingbox",
         pluginInstaller = "puzzlepiece.extension",
         modpackInstaller = "square.stack.3d.up"
    
    var id: String { rawValue }
    
    var title: LocalizedStringKey {
        switch self {
        case .info: "Dashboard"
        case .allocations: "Network"
        case .users: "Users"
        case .logs: "Logs"
        case .subdomains: "Subdomains"
        case .console: "Console"
        case .files: "Files"
        case .backup: "Backups"
        case .schedules: "Schedules"
        case .databases: "Databases"
        case .settings: "Settings"
        case .startup: "Startup"
        case .versionChanger: "Versions"
        case .modInstaller: "Mods"
        case .pluginInstaller: "Plugins"
        case .modpackInstaller: "Modpacks"
        }
    }
    
    var visibilityID: String {
        switch self {
        case .info: "info"
        case .allocations: "allocations"
        case .users: "users"
        case .logs: "logs"
        case .subdomains: "subdomains"
        case .console: "console"
        case .files: "files"
        case .backup: "backup"
        case .schedules: "schedules"
        case .databases: "databases"
        case .settings: "settings"
        case .startup: "startup"
        case .versionChanger: "versionChanger"
        case .modInstaller: "modInstaller"
        case .pluginInstaller: "pluginInstaller"
        case .modpackInstaller: "modpackInstaller"
        }
    }
}
