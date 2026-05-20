enum BillingMyService: Identifiable {
    case cloud(CloudServiceSummary),
         game(BillingGameServiceSummary),
         bot(BillingBotServiceSummary)
    
    var id: Int {
        switch self {
        case .cloud(let service): service.id
        case .game(let service): service.id
        case .bot(let service): service.id
        }
    }
    
    var listID: String {
        switch self {
        case .cloud(let service): "cloud-\(service.id)"
        case .game(let service): "game-\(service.id)"
        case .bot(let service): "bot-\(service.id)"
        }
    }
}
