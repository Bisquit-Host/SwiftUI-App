import SwiftUI

struct Bar: Identifiable {
    let id = UUID()
    
    let label: String
    let value: Int
    
    init(_ label: String, value: Int) {
        self.label = label
        self.value = value
    }
    
    static let sample = [
        Bar("Mon", value: 82),
        Bar("Tue", value: 51),
        Bar("Wed", value: 86),
        Bar("Thu", value: 45),
        Bar("Fri", value: 82)
    ]
}
