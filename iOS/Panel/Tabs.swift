import SwiftUI

enum Tabs: String, CaseIterable, Identifiable, Codable {
    case info = "info.circle",
         allocations = "link",
         users = "person.3",
         logs = "list.bullet.rectangle",
         subdomains = "globe",
         console = "terminal",
         files = "folder",
         backup = "externaldrive.badge.icloud",
         settings = "gearshape",
         startup = "play.circle",
         versionChanger = "arrow.clockwise.circle",
         modInstaller = "shippingbox",
         pluginInstaller = "puzzlepiece.extension",
         modpackInstaller = "square.stack.3d.up"
    
    var id: String { rawValue }
    
    var title: LocalizedStringKey {
        switch self {
        case .info: "Info"
        case .allocations: "Allocations"
        case .users: "Users"
        case .logs: "Logs"
        case .subdomains: "Subdomains"
        case .console: "Console"
        case .files: "Files"
        case .backup: "Data"
        case .settings: "Settings"
        case .startup: "Startup"
        case .versionChanger: "Version changer"
        case .modInstaller: "Mod installer"
        case .pluginInstaller: "Plugin installer"
        case .modpackInstaller: "Modpack installer"
        }
    }
}
