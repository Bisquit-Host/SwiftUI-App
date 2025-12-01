enum ServerSorting: String, CaseIterable, Identifiable {
    case none, runningFirst
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .none: "None"
        case .runningFirst: "Running first"
        }
    }
    
    var systemImage: String {
        switch self {
        case .none: "line.3.horizontal.decrease"
        case .runningFirst: "bolt.horizontal.circle"
        }
    }
}
