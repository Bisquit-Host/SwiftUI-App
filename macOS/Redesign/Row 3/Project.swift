import SwiftUI

struct Project: Identifiable {
    let id = UUID()
    let name: String
    let status: Status
    let progress: Double
    let done: Int
    let total: Int
    let due: Date
    let actors: [Person]
    
    enum Status {
        case inProgress, completed, onHold
        
        var title: String {
            switch self {
            case .inProgress: "In Progress"
            case .completed: "Completed"
            case .onHold: "On Hold"
            }
        }
        
        var bg: Color {
            switch self {
            case .inProgress: .blue.opacity(0.2)
            case .completed: .green.opacity(0.2)
            case .onHold: .gray.opacity(0.2)
            }
        }
    }
    
    static let sample: [Project] = [
        .init(name: "Fintech Project", status: .inProgress, progress: 0.7, done: 14, total: 20, due: .now, actors: [.michael]),
        .init(name: "Brodo Redesign", status: .completed, progress: 1, done: 25, total: 25, due: .now.addingTimeInterval(60 * 60 * 24 * 4), actors: [.john]),
        .init(name: "HR Setup", status: .onHold, progress: 0.7, done: 8, total: 20, due: .now.addingTimeInterval(60 * 60 * 24 * 66), actors: [.dawne])
    ]
}
