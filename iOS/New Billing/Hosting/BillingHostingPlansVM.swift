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
    var isOrdering = false
    
    private let baseURL = "https://test-api.bisquit.host/public-api"
    private let authedBase = URL(string: "https://test-api.bisquit.host")!
    
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
            filtered = plans.filter {
                $0.locationId == locationId
            }
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
    
    func loadOrderOptions(for category: BillingHostingCategory, planId: Int) async -> BillingHostingOrderOptions {
        var result = BillingHostingOrderOptions()
        
        switch category {
        case .cloud:
            guard let data = await request(path: "/cloud/os") else { break }
            let decoder = JSONDecoder()
            do {
                result.osCategories = try decoder.decode([BillingCloudOsCategory].self, from: data)
            } catch {
                lastError = error.localizedDescription
                print("Order OS decode error:", error)
            }
            
        case .game:
            guard let data = await request(path: "/game/packages/\(planId)/nests") else { break }
            let decoder = JSONDecoder()
            do {
                result.nests = try decoder.decode([BillingHostingNest].self, from: data)
            } catch {
                lastError = error.localizedDescription
                print("Order nests decode error (game):", error)
            }
            
        case .bot:
            guard let data = await request(path: "/bot/packages/\(planId)/nests") else { break }
            let decoder = JSONDecoder()
            do {
                result.nests = try decoder.decode([BillingHostingNest].self, from: data)
            } catch {
                lastError = error.localizedDescription
                print("Order nests decode error (bot):", error)
            }
        }
        
        return result
    }
    
    func order(plan: BillingHostingPlan, category: BillingHostingCategory, name: String, months: Int, osId: Int?, nestId: Int?, eggId: Int?) async -> BillingHostingOrderResponse? {
        guard !isOrdering else { return nil }
        isOrdering = true
        defer { isOrdering = false }
        lastError = nil
        
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            lastError = "Enter a name"
            return nil
        }
        
        guard [1, 3, 6, 12].contains(months) else {
            lastError = "Unsupported period"
            return nil
        }
        
        let path: String
        var body: [String: Any] = [
            "name": trimmed,
            "package": plan.id,
            "months": months
        ]
        
        switch category {
        case .cloud:
            guard let osId else {
                lastError = "Choose OS"
                return nil
            }
            path = "/cloud/order"
            body["os"] = osId
            
        case .game:
            guard let nestId, let eggId else {
                lastError = "Choose template"
                return nil
            }
            path = "/game/order"
            body["nest"] = nestId
            body["egg"] = eggId
            
        case .bot:
            guard let nestId, let eggId else {
                lastError = "Choose template"
                return nil
            }
            path = "/bot/order"
            body["nest"] = nestId
            body["egg"] = eggId
        }
        
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else {
            lastError = "Failed to encode order"
            return nil
        }
        
        guard let data = await request(path: path, method: "POST", body: payload) else { return nil }
        
        do {
            return try JSONDecoder().decode(BillingHostingOrderResponse.self, from: data)
        } catch {
            lastError = error.localizedDescription
            print("Order decode error:", error)
            if let raw = String(data: data, encoding: .utf8) {
                print("Order raw:", raw)
            }
            return nil
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
    
    private func request(path: String, method: String = "GET", body: Data? = nil) async -> Data? {
        let token = ValueStore().testAccessToken
        if token.isEmpty {
            lastError = "Please sign in"
            print("Order request missing token")
            return nil
        }
        
        guard let url = URL(string: path, relativeTo: authedBase) else {
            lastError = "Invalid URL"
            print("Order request invalid URL:", path)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                lastError = "No response"
                print("Order request missing HTTP response")
                return nil
            }
            
            guard (200...299).contains(http.statusCode) else {
                lastError = String(data: data, encoding: .utf8) ?? "Status \(http.statusCode)"
                print("Order request failed \(http.statusCode):", lastError ?? "")
                return nil
            }
            
            return data
        } catch {
            lastError = error.localizedDescription
            print("Order request failed:", error)
            return nil
        }
    }
}
