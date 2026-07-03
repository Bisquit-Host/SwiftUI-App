import Foundation

struct PanelCodexChatPreferencesRequest: Encodable {
    let codexModel: String
    let codexReasoningEffort: String
    let codexFastMode: Bool
    let webSearchEnabled: Bool
    let fullAccess: Bool

    init(codexModel: String, codexReasoningEffort: String, fastMode: String, webSearchEnabled: Bool, fullAccess: Bool) {
        self.codexModel = codexModel
        self.codexReasoningEffort = codexReasoningEffort
        codexFastMode = fastMode == "fast"
        self.webSearchEnabled = webSearchEnabled
        self.fullAccess = fullAccess
    }
    
    func jsonData() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
