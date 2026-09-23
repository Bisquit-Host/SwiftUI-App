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

    var name: String {
        switch self {
        case .cloud(let service): service.name
        case .game(let service): service.name
        case .bot(let service): service.name
        }
    }

    var state: BillingServiceState {
        switch self {
        case .cloud(let service): service.state
        case .game(let service): service.state
        case .bot(let service): service.state
        }
    }

    var flagUrl: String? {
        switch self {
        case .cloud(let service): service.locationFlagUrl
        case .game(let service): service.locationFlagUrl
        case .bot(let service): service.locationFlagUrl
        }
    }

    var location: String {
        switch self {
        case .cloud(let service): service.locationName
        case .game(let service): service.locationName
        case .bot(let service): service.locationName
        }
    }

    var system: String? {
        switch self {
        case .cloud(let service): service.system
        default: nil
        }
    }

    var ip: String? {
        switch self {
        case .cloud(let service): service.ip
        default: nil
        }
    }

}
