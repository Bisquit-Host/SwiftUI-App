enum BillingMyService: Identifiable {
    case cloud(BillingCloudServiceSummary),
         game(BillingGameServiceSummary),
         bot(BillingBotServiceSummary)
    
    var id: Int {
        switch self {
        case .cloud(let service): service.id
        case .game(let service): service.id
        case .bot(let service): service.id
        }
    }
}
