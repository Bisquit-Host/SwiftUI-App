import SwiftUI

struct PanelSection: Identifiable, Codable, Equatable {
    var name: String
    var isChecked: Bool
    
    init(_ name: String, isChecked: Bool = true) {
        self.name = name
        self.isChecked = isChecked
    }
    
    var id: String {
        name
    }
    
    var loc: LocalizedStringKey {
        LocalizedStringKey(name)
    }
}
