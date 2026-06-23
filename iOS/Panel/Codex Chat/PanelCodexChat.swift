import Calagopus

struct PanelCodexChat: Identifiable {
    let id: String
    let title: String
    let phase: String
    let configured: Bool
    let messages: [PanelCodexChatMessage]
    let pendingApproval: PanelCodexPendingApproval?

    init(_ json: CalagopusJSON) {
        let object = json.objectValue ?? [:]
        let parsedMessages = object["messages"]?.arrayValue?.compactMap(PanelCodexChatMessage.init) ?? []

        id = object["chatUuid"]?.stringValue ?? object["uuid"]?.stringValue ?? UUID().uuidString
        title = object["title"]?.stringValue ?? "Codex Chat"
        phase = object["phase"]?.stringValue ?? "idle"
        configured = object["configured"]?.boolValue ?? true
        messages = parsedMessages.sorted { $0.order < $1.order }
        pendingApproval = PanelCodexPendingApproval(object["pendingApproval"])
    }
}
