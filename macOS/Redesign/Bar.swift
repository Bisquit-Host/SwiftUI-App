import SwiftUI

struct Bar: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
    
    static let sample = [
        Bar(label: "Mon", value: 82),
        Bar(label: "Tue", value: 51),
        Bar(label: "Wed", value: 86),
        Bar(label: "Thu", value: 45),
        Bar(label: "Fri", value: 82)
    ]
}
