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
    let fastMode: String?
    let fastModeOptions: [String]
    let webSearchEnabled: Bool
    let fullAccess: Bool
    let messages: [PanelCodexChatMessage]
    let pendingApproval: PanelCodexPendingApproval?
    
    init(_ json: CalagopusJSON) {
        let object = json.objectValue ?? [:]
        let parsedMessages = object["messages"]?.arrayValue?.compactMap(PanelCodexChatMessage.init) ?? []
        
        id = object["chatUuid"]?.stringValue ?? object["uuid"]?.stringValue ?? UUID().uuidString
        title = object["title"]?.stringValue ?? "Codex Chat"
        phase = object["phase"]?.stringValue ?? "idle"
        configured = object["configured"]?.boolValue ?? true
        let parsedCodexModel = object["codexModel"]?.stringValue ?? object["model"]?.stringValue ?? "gpt-5"
        codexModel = parsedCodexModel
        codexModelOptions = object["codexModelOptions"]?.arrayValue?.compactMap(\.stringValue) ?? [codexModel]
        let parsedReasoningEffort = object["codexReasoningEffort"]?.stringValue ?? "medium"
        let parsedReasoningEffortOptions = object["codexReasoningEffortOptions"]?.arrayValue?.compactMap(\.stringValue).filter { $0 != "minimal" } ?? []
        codexReasoningEffort = parsedReasoningEffort == "minimal" ? "low" : parsedReasoningEffort
        codexReasoningEffortOptions = parsedReasoningEffortOptions.isEmpty ? ["low", "medium", "high", "xhigh"] : parsedReasoningEffortOptions
        if let parsedFastMode = object["fastMode"]?.stringValue ?? object["fast_mode"]?.stringValue {
            fastMode = parsedFastMode
        } else if let codexFastMode = object["codexFastMode"]?.boolValue ?? object["codex_fast_mode"]?.boolValue {
            fastMode = codexFastMode ? "fast" : "standard"
        } else {
            fastMode = nil
        }
        let parsedFastModeOptions = object["fastModeOptions"]?.arrayValue?.compactMap(\.stringValue) ?? object["fast_mode_options"]?.arrayValue?.compactMap(\.stringValue) ?? []
        fastModeOptions = parsedFastModeOptions.isEmpty ? ["standard", "fast"] : parsedFastModeOptions
        webSearchEnabled = object["webSearchEnabled"]?.boolValue ?? object["web_search_enabled"]?.boolValue ?? true
        fullAccess = object["fullAccess"]?.boolValue ?? object["full_access"]?.boolValue ?? false
        messages = parsedMessages.sorted { $0.order < $1.order }
        pendingApproval = PanelCodexPendingApproval(object["pendingApproval"])
    }
}
