import SwiftUI

enum PanelCodexChatTitle {
    case localized(String.LocalizationValue)
    case custom(String)
    
    init(_ title: String) {
        switch title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "codex chat":
            self = .localized("Codex Chat")
        case "new chat":
            self = .localized("New Chat")
        default:
            self = .custom(title)
        }
    }
    
    var text: String {
        switch self {
        case .localized(let value):
            String(localized: value)
        case .custom(let title):
            title
        }
    }
}
