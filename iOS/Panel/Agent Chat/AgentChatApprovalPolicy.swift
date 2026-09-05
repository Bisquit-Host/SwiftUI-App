import Calagopus

struct AgentChatApprovalPolicy: Identifiable, Hashable, Encodable {
    let id: String
    let label: String
    let description: String
    var enabled: Bool

    init?(_ json: CalagopusJSON) {
        guard let object = json.objectValue,
              let key = object["key"]?.stringValue,
              let label = object["label"]?.stringValue,
              let description = object["description"]?.stringValue else {
            return nil
        }

        id = key
        self.label = label
        self.description = description
        enabled = object["enabled"]?.boolValue ?? false
    }

    private enum CodingKeys: String, CodingKey {
        case id = "key"
        case enabled
    }
}
