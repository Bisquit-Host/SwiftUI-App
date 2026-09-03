enum AgentChatProvider: String, CaseIterable {
    case builtIn = "sponsored", codex = "codex_subscription", openAICompatible = "openai_compatible"

    var title: String {
        switch self {
        case .builtIn: "Built-in"
        case .codex: "Codex"
        case .openAICompatible: "API key"
        }
    }
}
