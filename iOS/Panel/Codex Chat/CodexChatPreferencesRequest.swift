import Foundation

struct CodexChatPreferencesRequest: Encodable {
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

    private enum CodingKeys: String, CodingKey {
        case codexModel = "codex_model"
        case codexReasoningEffort = "codex_reasoning_effort"
        case codexFastMode = "codex_fast_mode"
        case webSearchEnabled = "web_search_enabled"
        case fullAccess = "full_access"
    }
    
    func jsonData() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
