import SwiftUI

struct TaskItem: Identifiable {
    let id = UUID()
    
    let name: String
    let dateCreated: Date
    let project: ProjectTag
    
    static let sample: [TaskItem] = [
        .init(name: "File 1", dateCreated: .init(timeIntervalSinceNow: 0), project: .fintech),
        .init(name: "File 2", dateCreated: .init(timeIntervalSinceNow: 0), project: .brodo),
        .init(name: "File 3", dateCreated: .init(timeIntervalSinceNow: 0), project: .hr),
        .init(name: "File 4", dateCreated: .init(timeIntervalSinceNow: 0), project: .lucas),
        .init(name: "File 5", dateCreated: .init(timeIntervalSinceNow: 0), project: .allInOne)
    ]
}
