import SwiftUI

enum AppSettingsTab: String {
    case account, pterodactyl, debug
    
    var loc: LocalizedStringKey {
        switch self {
        case .account: "Account"
        case .pterodactyl: "Pterodactyl"
        case .debug: "Debug"
        }
    }
}
