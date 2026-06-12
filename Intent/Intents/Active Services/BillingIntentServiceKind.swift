#if os(iOS)
enum BillingIntentServiceKind: CaseIterable, Sendable {
    case cloud, game, bot
    
    nonisolated var endpointPath: String {
        switch self {
        case .cloud: "cloud"
        case .game: "game"
        case .bot: "bot"
        }
    }
    
    nonisolated var title: String {
        switch self {
        case .cloud: "Cloud"
        case .game: "Game"
        case .bot: "Bot"
        }
    }
}
#endif
