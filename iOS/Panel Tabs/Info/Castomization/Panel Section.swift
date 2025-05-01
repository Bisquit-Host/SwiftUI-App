import Foundation

struct PanelSection: Identifiable, Codable, Equatable {
    var id: String {
        name
    }
    
    var name: String
    var isChecked: Bool
    
    init(_ name: String, isChecked: Bool = true) {
        self.name = name
        self.isChecked = isChecked
    }
}
