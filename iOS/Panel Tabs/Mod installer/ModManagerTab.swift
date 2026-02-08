import Foundation

enum ModManagerTab: String, CaseIterable, Identifiable {
    case search, installed
    
    var id: String {
        rawValue
    }
}
