import SwiftUI

enum Tabs: String, CaseIterable, Identifiable, Codable {
    case info = "info.circle",
         console = "terminal",
         files = "folder",
         backup = "externaldrive.badge.icloud",
         startup = "play.circle",
         subdomain = "globe"
    
    var id: String {
        rawValue
    }
    
    var title: LocalizedStringKey {
        switch self {
        case .info: "Info"
        case .console: "Console"
        case .files: "Files"
        case .backup: "Data"
        case .startup: "Startup"
        case .subdomain: "Subdomains"
        }
    }
}
