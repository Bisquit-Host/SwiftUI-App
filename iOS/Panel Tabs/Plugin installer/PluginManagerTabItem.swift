import Foundation

enum PluginManagerTabItem: String, CaseIterable, Identifiable {
    case search, installed
    
    var id: String {
        rawValue
    }
}
