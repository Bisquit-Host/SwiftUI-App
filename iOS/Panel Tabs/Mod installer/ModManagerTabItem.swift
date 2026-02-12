import Foundation

enum ModManagerTabItem: String, CaseIterable, Identifiable {
    case search, installed
    
    var id: String {
        rawValue
    }
}
