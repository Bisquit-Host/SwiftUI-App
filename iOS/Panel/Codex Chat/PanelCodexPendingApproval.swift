import Calagopus

struct PanelCodexPendingApproval: Hashable {
    let toolName: String
    let summary: String
    let server: String?

    init?(_ json: CalagopusJSON?) {
        guard let object = json?.objectValue else { return nil }

        toolName = object["toolName"]?.stringValue ?? "Tool"
        summary = object["summary"]?.stringValue ?? ""
        server = object["server"]?.stringValue
    }
}
