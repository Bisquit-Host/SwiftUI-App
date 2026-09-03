import Foundation

struct CodexChatPreferencesRequest: Encodable {
    let provider: String
    let codexModel: String?
    let codexReasoningEffort: String?
    let codexFastMode: Bool?
    let sponsoredModel: String?
    let sponsoredReasoningEffort: String?
    let webSearchEnabled: Bool
    let fullAccess: Bool
    let approvalPolicies: [CodexChatApprovalPolicy]

    init(
        provider: CodexChatProvider,
        codexModel: String,
        codexReasoningEffort: String,
        fastMode: String,
        builtInModel: String,
        builtInReasoningEffort: String?,
        webSearchEnabled: Bool,
        fullAccess: Bool,
        approvalPolicies: [CodexChatApprovalPolicy]
    ) {
        self.provider = provider.rawValue
        self.codexModel = provider == .codex ? codexModel : nil
        self.codexReasoningEffort = provider == .codex ? codexReasoningEffort : nil
        codexFastMode = provider == .codex ? fastMode == "fast" : nil
        sponsoredModel = provider == .builtIn && !builtInModel.isEmpty ? builtInModel : nil
        sponsoredReasoningEffort = provider == .builtIn ? builtInReasoningEffort : nil
        self.webSearchEnabled = webSearchEnabled
        self.fullAccess = fullAccess
        self.approvalPolicies = approvalPolicies
    }

    private enum CodingKeys: String, CodingKey {
        case provider
        case codexModel = "codex_model"
        case codexReasoningEffort = "codex_reasoning_effort"
        case codexFastMode = "codex_fast_mode"
        case sponsoredModel = "sponsored_model"
        case sponsoredReasoningEffort = "sponsored_reasoning_effort"
        case webSearchEnabled = "web_search_enabled"
        case fullAccess = "full_access"
        case approvalPolicies = "approval_policies"
    }

    func jsonData() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
