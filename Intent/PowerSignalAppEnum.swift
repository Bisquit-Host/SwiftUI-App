import AppIntents

enum PowerSignalAppEnum: String, AppEnum {
    case start, stop, restart, kill
    
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Power Signal")
    
    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .start:   "Start",
        .stop:    "Stop",
        .restart: "Restart",
        .kill:    "Kill"
    ]
}
