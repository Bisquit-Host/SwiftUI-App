enum Tabs: String, CaseIterable {
    case info = "info.circle"
    case console = "terminal"
    case files = "folder"
    case backup = "externaldrive.badge.icloud"
    
    var title: String {
        switch self {
        case .info: "Info"
        case .console: "Console"
        case .files: "Files"
        case .backup: "Data"
        }
    }
}
