import SwiftUI

enum BillingAnyService: Identifiable {
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

struct BillingServiceRow: View {
    private let service: BillingAnyService
    
    init(_ service: BillingAnyService) {
        self.service = service
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .subheadline(.semibold)
                
                Spacer()
                
                Label(state.title, systemImage: "circle.fill")
                    .labelStyle(.titleAndIcon)
                    .caption(.semibold)
                    .foregroundStyle(state.color)
            }
            
            HStack(spacing: 6) {
                if let flag = flagUrl, let url = URL(string: flag) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: 20, height: 14)
                                .clipShape(.rect(cornerRadius: 2))
                        default:
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.gray.opacity(0.2))
                                .frame(width: 20, height: 14)
                        }
                    }
                }
                
                Text(location)
                    .footnote()
                    .secondary()
                
                if let system {
                    Text("• \(system)")
                        .footnote()
                        .secondary()
                }
            }
            
            HStack {
                if let ip {
                    Label(ip, systemImage: "network")
                        .footnote()
                        .secondary()
                }
                
                Spacer()
                
                Text(priceText)
                    .footnote()
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 6)
    }
    
    private var name: String {
        switch service {
        case .cloud(let service): service.name
        case .game(let service): service.name
        case .bot(let service): service.name
        }
    }
    
    private var state: BillingServiceState {
        switch service {
        case .cloud(let service): service.state
        case .game(let service): service.state
        case .bot(let service): service.state
        }
    }
    
    private var flagUrl: String? {
        switch service {
        case .cloud(let service): service.locationFlagUrl
        case .game(let service): service.locationFlagUrl
        case .bot(let service): service.locationFlagUrl
        }
    }
    
    private var location: String {
        switch service {
        case .cloud(let service): service.locationName
        case .game(let service): service.locationName
        case .bot(let service): service.locationName
        }
    }
    
    private var system: String? {
        switch service {
        case .cloud(let service): service.system
        default: nil
        }
    }
    
    private var ip: String? {
        switch service {
        case .cloud(let service): service.ip
        default: nil
        }
    }
    
    private var priceText: String {
        let price: Double
        switch service {
        case .cloud(let service): price = service.price
        case .game(let service): price = service.price
        case .bot(let service): price = service.price
        }
        return "\(Int(price))₽/mo"
    }
}
