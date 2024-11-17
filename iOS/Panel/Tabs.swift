enum Tabs: String, CaseIterable {
    case info = "info.circle"
    case console = "terminal"
    case files = "folder"
    case backup = "externaldrive.badge.icloud"
    case startup = "play.circle"
    
    var title: String {
        switch self {
        case .info: "Info"
        case .console: "Console"
        case .files: "Files"
        case .backup: "Data"
        case .startup: "Startup"
        }
    }
}
