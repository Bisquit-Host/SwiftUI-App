import SwiftUI

struct Person: Identifiable {
    let id = UUID()
    
    let name: String
    let initials: String
    let tint: Color
    
    init(_ name: String, initials: String, tint: Color) {
        self.name = name
        self.initials = initials
        self.tint = tint
    }
    
    static let michael = Person("Michael M", initials: "MM", tint: .orange)
    static let john = Person("John C", initials: "JC", tint: .purple)
    static let dawne = Person("Dawne A", initials: "DA", tint: .blue)
}
