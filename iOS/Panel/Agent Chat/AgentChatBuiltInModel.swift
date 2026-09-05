import Calagopus

struct AgentChatBuiltInModel: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let supportsImages: Bool
    let reasoningEfforts: [String]

    init?(_ json: CalagopusJSON) {
        guard let object = json.objectValue,
              let id = object["slug"]?.stringValue,
              !id.isEmpty else {
            return nil
        }

        self.id = id
        title = object["label"]?.stringValue.flatMap { $0.isEmpty ? nil : $0 } ?? id
        description = object["description"]?.stringValue ?? ""
        supportsImages = object["supportsImages"]?.boolValue ?? false
        reasoningEfforts = object["reasoningEfforts"]?.arrayValue?.compactMap(\.stringValue) ?? []
    }
}
