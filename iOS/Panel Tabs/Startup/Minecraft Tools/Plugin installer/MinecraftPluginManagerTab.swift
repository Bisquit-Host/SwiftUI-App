import Foundation

enum MinecraftPluginManagerTab: String, CaseIterable, Identifiable {
    case search, installed
    
    var id: String {
        rawValue
    }
}
