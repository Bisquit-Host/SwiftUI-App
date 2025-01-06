import SwiftUI

enum Tabs: String, CaseIterable {
    case info = "info.circle",
         console = "terminal",
         files = "folder",
         backup = "externaldrive.badge.icloud",
         startup = "play.circle"
    
    var title: LocalizedStringKey {
        switch self {
        case .info: "Info"
        case .console: "Console"
        case .files: "Files"
        case .backup: "Data"
        case .startup: "Startup"
        }
    }
}
