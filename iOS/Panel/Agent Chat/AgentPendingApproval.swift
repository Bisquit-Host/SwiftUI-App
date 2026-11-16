import Calagopus

struct AgentPendingApproval: Hashable {
    let toolName: String
    let summary: String
    let server: String?
    let questions: [AgentQuestion]
    
    init?(_ json: CalagopusJSON?) {
        guard let object = json?.objectValue else { return nil }
        
        toolName = object["toolName"]?.stringValue ?? "Tool"
        summary = object["summary"]?.stringValue ?? ""
        server = object["server"]?.stringValue
        questions = object["questions"]?.arrayValue?.compactMap(AgentQuestion.init) ?? []
    }
}
