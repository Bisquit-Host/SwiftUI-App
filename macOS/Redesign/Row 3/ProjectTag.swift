import SwiftUI

struct ProjectTag: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    
    static let fintech = ProjectTag(name: "Fintech Project", color: .blue)
    static let brodo = ProjectTag(name: "Brodo Redesign", color: .purple)
    static let hr = ProjectTag(name: "HR Setup", color: .cyan)
    static let lucas = ProjectTag(name: "Lucas Projects", color: .indigo)
    static let allInOne = ProjectTag(name: "All in One Project", color: .pink)
}
