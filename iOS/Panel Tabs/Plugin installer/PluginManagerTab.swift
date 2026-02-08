import Foundation

enum PluginManagerTab: String, CaseIterable, Identifiable {
    case search, installed
    
    var id: String {
        rawValue
    }
}
