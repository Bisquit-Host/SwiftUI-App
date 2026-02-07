import Foundation

enum MinecraftModManagerTab: String, CaseIterable, Identifiable {
    case search, installed
    
    var id: String {
        rawValue
    }
}
