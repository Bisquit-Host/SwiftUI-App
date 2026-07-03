import Foundation

struct PanelCodexChatPreferencesRequest: Encodable {
    let codexModel: String
    let codexReasoningEffort: String
    let fastMode: String
    let webSearchEnabled: Bool
    let fullAccess: Bool
    
    func jsonData() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
