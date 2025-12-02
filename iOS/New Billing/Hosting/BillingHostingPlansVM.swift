import Foundation

@Observable
final class BillingHostingPlansVM {
    var botPlans: [BillingHostingPlan] = []
    var gamePlans: [BillingHostingPlan] = []
    var cloudPlans: [BillingHostingPlan] = []
    
    var botLocations: [BillingHostingLocation] = []
    var gameLocations: [BillingHostingLocation] = []
    var cloudLocations: [BillingHostingLocation] = []
    
    var isLoading = false
    var lastError: String?
    
    private let baseURL = "https://test-api.bisquit.host/public-api"
    
    func loadAll() async {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        async let bot: () = fetch(.bot)
        async let game: () = fetch(.game)
        async let cloud: () = fetch(.cloud)
        
        _ = await (bot, game, cloud)
    }
    
    func plans(for category: BillingHostingCategory, currency: String?, locationId: Int? = nil) -> [BillingHostingPlan] {
        let plans: [BillingHostingPlan]
        
        switch category {
        case .bot: plans = botPlans
        case .game: plans = gamePlans
        case .cloud: plans = cloudPlans
        }
        
        let filtered: [BillingHostingPlan]
        
        if let locationId {
            filtered = plans.filter { $0.locationId == locationId }
        } else {
            filtered = plans
        }
        
        return filtered.sorted { lhs, rhs in
            priceValue(for: lhs, currency: currency) < priceValue(for: rhs, currency: currency)
        }
    }
    
    func locations(for category: BillingHostingCategory) -> [BillingHostingLocation] {
        switch category {
        case .bot: botLocations
        case .game: gameLocations
        case .cloud: cloudLocations
        }
    }
    
    func location(for plan: BillingHostingPlan, in category: BillingHostingCategory) -> BillingHostingLocation? {
        let pool: [BillingHostingLocation]
        
        switch category {
        case .bot: pool = botLocations
        case .game: pool = gameLocations
        case .cloud: pool = cloudLocations
        }
        
        return pool.first {
            $0.id == plan.locationId
        }
    }
    
    func formattedPrice(for plan: BillingHostingPlan, currency: String?) -> String {
        let code = currency?.uppercased()
        let entry = plan.price.first { $0.currency.uppercased() == code } ?? plan.price.first
        
        guard let entry else { return "N/A" }
        
        let symbol = symbol(for: entry.currency)
        let value = entry.price
        let formatted = value.rounded() == value ? String(Int(value)) : String(format: "%.2f", value)
        
        return "\(symbol)\(formatted)"
    }
    
    private func fetch(_ category: BillingHostingCategory) async {
        guard let url = URL(string: "\(baseURL)/\(category.path)") else {
            lastError = "Invalid URL"
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                lastError = "Request failed: \(http.statusCode)"
                print("Hosting plans", category.rawValue, "failed", http.statusCode)
                return
            }
            
            let decoded = try JSONDecoder().decode(BillingHostingPlansResponse.self, from: data)
            
            switch category {
            case .bot:
                botPlans = decoded.packages
                botLocations = decoded.locations ?? []
                
            case .game:
                gamePlans = decoded.packages
                gameLocations = decoded.locations ?? []
                
            case .cloud:
                cloudPlans = decoded.packages
                cloudLocations = decoded.locations ?? []
            }
        } catch {
            lastError = error.localizedDescription
            print("Hosting plans", category.rawValue, "decode error:", error)
        }
    }
    
    private func priceValue(for plan: BillingHostingPlan, currency: String?) -> Double {
        let code = currency?.uppercased()
        return plan.price.first { $0.currency.uppercased() == code }?.price ?? plan.price.first?.price ?? 0
    }
    
    private func symbol(for currency: String) -> String {
        switch currency.uppercased() {
        case "RUB": "₽"
        case "EUR": "€"
        case "USD": "$"
        default: currency.uppercased()
        }
    }
}
