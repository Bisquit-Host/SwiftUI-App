import Foundation

enum CodexChatImageInputError: LocalizedError {
    case tooMany
    case tooLarge(String)
    case unsupported(String)
    case unreadable

    var errorDescription: String? {
        switch self {
        case .tooMany:
            String(localized: "You can attach up to 4 images to one message")
        case .tooLarge(let name):
            String(localized: "\(name) is larger than 5 MiB")
        case .unsupported(let name):
            String(localized: "\(name) is not a supported image. Use PNG, JPEG, GIF, or WebP")
        case .unreadable:
            String(localized: "The selected image could not be read")
        }
    }
}
