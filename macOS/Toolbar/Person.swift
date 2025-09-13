import SwiftUI

struct Person: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let tint: Color
    
    static let michael = Person(name: "Michael M", initials: "MM", tint: .orange)
    static let john = Person(name: "John C", initials: "JC", tint: .purple)
    static let dawne = Person(name: "Dawne A", initials: "DA", tint: .blue)
}
