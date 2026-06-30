import Calagopus

struct PanelCodexChat: Identifiable {
    let id: String
    let title: String
    let phase: String
    let configured: Bool
    let codexModel: String
    let codexModelOptions: [String]
    let codexReasoningEffort: String
    let codexReasoningEffortOptions: [String]
    let messages: [PanelCodexChatMessage]
    let pendingApproval: PanelCodexPendingApproval?
    
    init(_ json: CalagopusJSON) {
        let object = json.objectValue ?? [:]
        let parsedMessages = object["messages"]?.arrayValue?.compactMap(PanelCodexChatMessage.init) ?? []
        
        id = object["chatUuid"]?.stringValue ?? object["uuid"]?.stringValue ?? UUID().uuidString
        title = object["title"]?.stringValue ?? "Codex Chat"
        phase = object["phase"]?.stringValue ?? "idle"
        configured = object["configured"]?.boolValue ?? true
        codexModel = object["codexModel"]?.stringValue ?? object["model"]?.stringValue ?? "gpt-5"
        codexModelOptions = object["codexModelOptions"]?.arrayValue?.compactMap(\.stringValue) ?? [codexModel]
        let parsedReasoningEffort = object["codexReasoningEffort"]?.stringValue ?? "medium"
        let parsedReasoningEffortOptions = object["codexReasoningEffortOptions"]?.arrayValue?.compactMap(\.stringValue).filter { $0 != "minimal" } ?? []
        codexReasoningEffort = parsedReasoningEffort == "minimal" ? "low" : parsedReasoningEffort
        codexReasoningEffortOptions = parsedReasoningEffortOptions.isEmpty ? ["low", "medium", "high", "extra_high"] : parsedReasoningEffortOptions
        messages = parsedMessages.sorted { $0.order < $1.order }
        pendingApproval = PanelCodexPendingApproval(object["pendingApproval"])
    }
}
