import Foundation
import BisquitoNet
import PteroNet

@Observable
final class HostingPlanListVM {
    var botPlans: [BillingHostingPlan] = []
    var gamePlans: [BillingHostingPlan] = []
    var cloudPlans: [BillingHostingPlan] = []
    
    var botLocations: [HostingLocation] = []
    var gameLocations: [HostingLocation] = []
    var cloudLocations: [HostingLocation] = []
    
    var isLoading = false
    var isOrdering = false
    
    private let authedBase = URL(string: Endpoint.basePath)!
    
    func loadAll(currency: BillingCurrency? = nil) async {
        isLoading = true
        defer { isLoading = false }
        
        let effectiveCurrency = currency ?? .RUB
        
        async let bot: () = fetch(.bot, currency: effectiveCurrency)
        async let game: () = fetch(.game, currency: effectiveCurrency)
        async let cloud: () = fetch(.cloud, currency: effectiveCurrency)
        
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
    
    func locations(for category: BillingHostingCategory) -> [HostingLocation] {
        switch category {
        case .bot: botLocations
        case .game: gameLocations
        case .cloud: cloudLocations
        }
    }
    
    func location(for plan: BillingHostingPlan, in category: BillingHostingCategory) -> HostingLocation? {
        let pool: [HostingLocation]
        
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
        let entry = plan.price.first { $0.currency.rawValue == code } ?? plan.price.first
        
        guard let entry else { return "N/A" }
        
        let value = entry.price
        let formatted = value.rounded() == value ? String(Int(value)) : value.formatted(.fractionDigits(2))
        
        return "\(entry.currency.symbol)\(formatted)"
    }
    
    private func fetch(_ category: BillingHostingCategory, currency: BillingCurrency) async {
        async let plans = fetchPackages(for: category, currency: currency)
        async let locations = fetchLocations(for: category)
        
        let (plansResult, locationsResult) = await (plans, locations)
        
        switch category {
        case .bot:
            if let plansResult { botPlans = plansResult }
            if let locationsResult { botLocations = locationsResult }
            
        case .game:
            if let plansResult { gamePlans = plansResult }
            if let locationsResult { gameLocations = locationsResult }
            
        case .cloud:
            if let plansResult { cloudPlans = plansResult }
            if let locationsResult { cloudLocations = locationsResult }
        }
    }

    private func fetchPackages(for category: BillingHostingCategory, currency: BillingCurrency) async -> [BillingHostingPlan]? {
        guard let data = await request(path: "/\(category.path)/packages") else { return nil }
        
        do {
            switch category {
            case .bot:
                let packages = try BigAssDecoder.decode([PrivateBotPackage].self, from: data)
                return packages.map { $0.toBillingPlan(currency: currency) }
                
            case .game:
                let packages = try BigAssDecoder.decode([PrivateGamePackage].self, from: data)
                return packages.map { $0.toBillingPlan(currency: currency) }
                
            case .cloud:
                let packages = try BigAssDecoder.decode([PrivateCloudPackage].self, from: data)
                return packages.map { $0.toBillingPlan(currency: currency) }
            }
        } catch {
            SystemAlert.error("Hosting plans request failed", subtitle: "\(category.rawValue) • \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchLocations(for category: BillingHostingCategory) async -> [HostingLocation]? {
        guard let data = await request(path: "/\(category.path)/locations") else { return nil }
        
        do {
            return try BigAssDecoder.decode([HostingLocation].self, from: data)
        } catch {
            SystemAlert.error("Hosting locations request failed", subtitle: "\(category.rawValue) • \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadOrderOptions(for category: BillingHostingCategory, planId: Int) async -> BillingHostingOrderOptions {
        var result = BillingHostingOrderOptions()
        
        switch category {
        case .cloud:
            guard let data = await request(path: "/cloud/os") else { break }
            
            do {
                result.osCategories = try BigAssDecoder.decode([CloudServiceOSCategory].self, from: data)
            } catch {
                SystemAlert.error("Error decoding order OS", subtitle: error.localizedDescription)
            }
            
        case .game:
            guard let data = await request(path: "/game/packages/\(planId)/nests") else { break }
            
            do {
                result.nests = try BigAssDecoder.decode([BillingHostingNest].self, from: data)
            } catch {
                SystemAlert.error("Error decoding game nests", subtitle: error.localizedDescription)
            }
            
        case .bot:
            guard let data = await request(path: "/bot/packages/\(planId)/nests") else { break }
            
            do {
                result.nests = try BigAssDecoder.decode([BillingHostingNest].self, from: data)
            } catch {
                SystemAlert.error("Error decoding order nests (bot)", subtitle: error.localizedDescription)
            }
        }
        
        return result
    }
    
    func order(context: BillingPlanOrderContext, name: String, months: Int, osId: Int?, nestId: Int?, eggId: Int?) async -> BillingHostingOrderResponse? {
        guard !isOrdering else { return nil }
        
        isOrdering = true
        defer { isOrdering = false }
        
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            SystemAlert.error("Enter a name")
            return nil
        }
        
        guard [1, 3, 6, 12].contains(months) else {
            SystemAlert.error("Invalid billing period")
            return nil
        }
        
        let path: String
        
        var body: [String: Any] = [
            "name": trimmed,
            "package": context.plan.id,
            "months": months
        ]
        
        switch context.category {
        case .cloud:
            guard let osId else {
                SystemAlert.error("Choose OS")
                return nil
            }
            
            path = "/cloud/order"
            body["os"] = osId
            
        case .game:
            guard let nestId, let eggId else {
                SystemAlert.error("Choose template")
                return nil
            }
            
            path = "/game/order"
            body["nest"] = nestId
            body["egg"] = eggId
            
        case .bot:
            guard let nestId, let eggId else {
                SystemAlert.error("Choose template")
                return nil
            }
            
            path = "/bot/order"
            body["nest"] = nestId
            body["egg"] = eggId
        }
        
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else {
            SystemAlert.error("Failed to encode order")
            return nil
        }
        
        guard let data = await request(path: path, method: "POST", body: payload) else { return nil }
        
        do {
            return try BigAssDecoder.decode(BillingHostingOrderResponse.self, from: data)
        } catch {
            SystemAlert.error("Order error", subtitle: error.localizedDescription)
            
            if let raw = String(data: data, encoding: .utf8) {
                Logger().info("Order raw: \(raw)")
            }
            
            return nil
        }
    }
    
    private func priceValue(for plan: BillingHostingPlan, currency: String?) -> Double {
        let code = currency?.uppercased()
        return plan.price.first { $0.currency.rawValue == code }?.price ?? plan.price.first?.price ?? 0
    }
    
    private func request(path: String, method: String = "GET", body: Data? = nil) async -> Data? {
        guard let accessToken = accessToken() else { return nil }
        
        guard let url = URL(string: path, relativeTo: authedBase) else {
            SystemAlert.error("Order failed", subtitle: "Invalid URL: \(path)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            
            if decodeBillingError(data, with: res, onDecode: SystemAlert.error) {
                return nil
            }
            
            return data
        } catch {
            SystemAlert.error("Order request failed", subtitle: error.localizedDescription)
            return nil
        }
    }
}

private struct PrivateBotPackage: Decodable {
    let id: Int
    let name: String
    let locationId: Int
    let price: Double
    let cpu: Double
    let cpuName: String?
    let memory: Double
    let memoryType: String
    let disk: Double
    let diskType: String?
    let nests: [Int]
    let allocations: Int
    let databases: Int
    let backups: Int
    let bonusBalanceAllowed: Bool
    let whmcsLink: String?
}

private struct PrivateGamePackage: Decodable {
    let id: Int
    let name: String
    let locationId: Int
    let price: Double
    let cpu: Double
    let cpuName: String?
    let memory: Double
    let memoryType: String
    let disk: Double
    let diskType: String?
    let network: Double
    let networkType: String?
    let nests: [Int]
    let allocations: Int
    let databases: Int
    let backups: Int
    let bonusBalanceAllowed: Bool
    let whmcsLink: String?
}

private struct PrivateCloudPackage: Decodable {
    let id: Int
    let name: String
    let locationId: Int
    let price: Double
    let cpu: Double
    let cpuName: String?
    let memory: Double
    let disk: Double
    let diskType: String?
    let network: Double
    let networkType: String?
    let bonusBalanceAllowed: Bool
    let windowsAllowed: Bool
    let antiSpoofing: Bool
    let whmcsLink: String?
}

private func billingPriceList(_ price: Double, currency: BillingCurrency) -> [BillingHostingPlanPrice] {
    [BillingHostingPlanPrice(price: price, currency: currency)]
}

private extension PrivateBotPackage {
    func toBillingPlan(currency: BillingCurrency) -> BillingHostingPlan {
        BillingHostingPlan(
            id: id,
            name: name,
            locationId: locationId,
            price: billingPriceList(price, currency: currency),
            cpu: cpu,
            cpuName: cpuName,
            memory: memory,
            memoryType: memoryType,
            disk: disk,
            diskType: diskType,
            network: nil,
            networkType: nil,
            nests: nests,
            allocations: allocations,
            databases: databases,
            backups: backups,
            bonusBalanceAllowed: bonusBalanceAllowed,
            windowsAllowed: nil,
            antiSpoofing: nil,
            whmcsLink: whmcsLink
        )
    }
}

private extension PrivateGamePackage {
    func toBillingPlan(currency: BillingCurrency) -> BillingHostingPlan {
        BillingHostingPlan(
            id: id,
            name: name,
            locationId: locationId,
            price: billingPriceList(price, currency: currency),
            cpu: cpu,
            cpuName: cpuName,
            memory: memory,
            memoryType: memoryType,
            disk: disk,
            diskType: diskType,
            network: network,
            networkType: networkType,
            nests: nests,
            allocations: allocations,
            databases: databases,
            backups: backups,
            bonusBalanceAllowed: bonusBalanceAllowed,
            windowsAllowed: nil,
            antiSpoofing: nil,
            whmcsLink: whmcsLink
        )
    }
}

private extension PrivateCloudPackage {
    func toBillingPlan(currency: BillingCurrency) -> BillingHostingPlan {
        BillingHostingPlan(
            id: id,
            name: name,
            locationId: locationId,
            price: billingPriceList(price, currency: currency),
            cpu: cpu,
            cpuName: cpuName,
            memory: memory,
            memoryType: nil,
            disk: disk,
            diskType: diskType,
            network: network,
            networkType: networkType,
            nests: nil,
            allocations: nil,
            databases: nil,
            backups: nil,
            bonusBalanceAllowed: bonusBalanceAllowed,
            windowsAllowed: windowsAllowed,
            antiSpoofing: antiSpoofing,
            whmcsLink: whmcsLink
        )
    }
}
