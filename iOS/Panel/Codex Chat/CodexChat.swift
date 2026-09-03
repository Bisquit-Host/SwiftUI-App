import Calagopus

struct CodexChat: Identifiable {
    let id: String
    let title: String
    let phase: String
    let configured: Bool
    let provider: CodexChatProvider
    let codexModel: String
    let codexModelOptions: [String]
    let codexReasoningEffort: String
    let codexReasoningEffortOptions: [String]
    let fastMode: String
    let fastModeOptions: [String]
    let builtInModel: String
    let builtInReasoningEffort: String
    let builtInModelOptions: [CodexChatBuiltInModel]
    let webSearchEnabled: Bool
    let fullAccess: Bool
    let messages: [CodexChatMessage]
    let pendingApproval: CodexPendingApproval?
    
    init(_ json: CalagopusJSON) {
        let object = json.objectValue ?? [:]
        let parsedMessages = object["messages"]?.arrayValue?.compactMap(CodexChatMessage.init) ?? []
        
        id = object["chatUuid"]?.stringValue ?? UUID().uuidString
        title = object["title"]?.stringValue ?? "Codex Chat"
        phase = object["phase"]?.stringValue ?? "idle"
        configured = object["configured"]?.boolValue ?? true
        provider = CodexChatProvider(rawValue: object["provider"]?.stringValue ?? "") ?? .codex
        let parsedCodexModel = object["codexModel"]?.stringValue ?? "gpt-5.6-sol"
        codexModel = parsedCodexModel
        codexModelOptions = object["codexModelOptions"]?.arrayValue?.compactMap(\.stringValue) ?? [codexModel]
        let parsedReasoningEffort = object["codexReasoningEffort"]?.stringValue ?? "medium"
        let parsedReasoningEffortOptions = object["codexReasoningEffortOptions"]?.arrayValue?.compactMap(\.stringValue) ?? []
        codexReasoningEffort = parsedReasoningEffort
        codexReasoningEffortOptions = parsedReasoningEffortOptions.isEmpty ? ["light", "medium", "high", "xhigh"] : parsedReasoningEffortOptions
        fastMode = object["codexFastMode"]?.boolValue == true ? "fast" : "standard"
        let fastModeModels = object["codexFastModeModels"]?.arrayValue?.compactMap(\.stringValue) ?? []
        fastModeOptions = fastModeModels.contains(codexModel) ? ["standard", "fast"] : ["standard"]
        let parsedBuiltInModels = object["sponsoredModelOptions"]?.arrayValue?.compactMap(CodexChatBuiltInModel.init) ?? []
        let parsedBuiltInModel = object["sponsoredModel"]?.stringValue ?? parsedBuiltInModels.first?.id ?? ""
        builtInModel = parsedBuiltInModel
        builtInModelOptions = parsedBuiltInModels
        let builtInReasoningEfforts = parsedBuiltInModels.first { $0.id == parsedBuiltInModel }?.reasoningEfforts ?? []
        builtInReasoningEffort = object["sponsoredReasoningEffort"]?.stringValue ?? builtInReasoningEfforts.first ?? ""
        webSearchEnabled = object["webSearchEnabled"]?.boolValue ?? true
        fullAccess = object["fullAccess"]?.boolValue ?? false
        messages = parsedMessages.sorted { $0.order < $1.order }
        pendingApproval = CodexPendingApproval(object["pendingApproval"])
    }
}
