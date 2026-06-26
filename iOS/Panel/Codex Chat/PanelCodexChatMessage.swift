import Calagopus

struct PanelCodexChatMessage: Identifiable, Hashable {
    let id: String
    let order: Int
    let role: String
    let content: String
    
    var isUser: Bool {
        role == "user"
    }
    
    init?(_ json: CalagopusJSON) {
        guard let object = json.objectValue else { return nil }
        
        id = object["id"]?.stringValue ?? UUID().uuidString
        order = object["order"]?.intValue ?? 0
        role = object["role"]?.stringValue ?? "assistant"
        content = object["content"]?.stringValue ?? ""
    }
}
