import Foundation
import BisquitoNet

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
    var topupAlertContext: TopupAlertContext?
    
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
        
        let formatted = formatCurrencyValue(
            entry.price,
            currency: entry.currency,
            minimumFractionDigits: 0,
            maximumFractionDigits: entry.currency.fractionDigits
        )
        
        return "\(entry.currency.displaySymbol)\(formatted)"
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
        guard let accessToken = accessToken() else { return nil }
        
        let onBillingError: @MainActor (String, String) -> Void = { title, subtitle in
            self.handleBillingError(title, subtitle: subtitle)
        }
        
        switch category {
        case .bot:
            let packages: [PrivateBotPackage]? = await fetchHostingPackagesAPI(
                categoryPath: category.path,
                accessToken: accessToken,
                onBillingError: onBillingError
            )
            
            return packages?.map { $0.toBillingPlan(currency: currency) }
            
        case .game:
            let packages: [PrivateGamePackage]? = await fetchHostingPackagesAPI(
                categoryPath: category.path,
                accessToken: accessToken,
                onBillingError: onBillingError
            )
            
            return packages?.map { $0.toBillingPlan(currency: currency) }
            
        case .cloud:
            let packages: [PrivateCloudPackage]? = await fetchHostingPackagesAPI(
                categoryPath: category.path,
                accessToken: accessToken,
                onBillingError: onBillingError
            )
            
            return packages?.map { $0.toBillingPlan(currency: currency) }
        }
    }
    
    private func fetchLocations(for category: BillingHostingCategory) async -> [HostingLocation]? {
        guard let accessToken = accessToken() else { return nil }
        
        let onBillingError: @MainActor (String, String) -> Void = { title, subtitle in
            self.handleBillingError(title, subtitle: subtitle)
        }
        
        let locations: [HostingLocation]? = await fetchHostingLocationsAPI(
            categoryPath: category.path,
            accessToken: accessToken,
            onBillingError: onBillingError
        )
        
        return locations
    }
    
    func loadOrderOptions(for category: BillingHostingCategory, planID: Int) async -> BillingHostingOrderOptions {
        var result = BillingHostingOrderOptions()
        
        guard let accessToken = accessToken() else { return result }
        
        let onBillingError: @MainActor (String, String) -> Void = { title, subtitle in
            self.handleBillingError(title, subtitle: subtitle)
        }
        
        switch category {
        case .cloud:
            let categories: [CloudServiceOSCategory]? = await fetchHostingOSCategoriesAPI(
                accessToken: accessToken,
                onBillingError: onBillingError
            )
            result.osCategories = categories ?? []
            
        case .game:
            let nests: [BillingHostingNest]? = await fetchHostingNestsAPI(
                categoryPath: category.path,
                packageId: planID,
                accessToken: accessToken,
                onBillingError: onBillingError
            )
            result.nests = nests ?? []
            
        case .bot:
            let nests: [BillingHostingNest]? = await fetchHostingNestsAPI(
                categoryPath: category.path,
                packageId: planID,
                accessToken: accessToken,
                onBillingError: onBillingError
            )
            result.nests = nests ?? []
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
        
        let orderOSId: Int?
        let orderNestID: Int?
        let orderEggID: Int?

        switch context.category {
        case .cloud:
            guard let osId else {
                SystemAlert.error("Choose OS")
                return nil
            }
            
            orderOSId = osId
            orderNestID = nil
            orderEggID = nil
            
        case .game:
            guard let nestId, let eggId else {
                SystemAlert.error("Choose template")
                return nil
            }
            
            orderOSId = nil
            orderNestID = nestId
            orderEggID = eggId
            
        case .bot:
            guard let nestId, let eggId else {
                SystemAlert.error("Choose template")
                return nil
            }
            
            orderOSId = nil
            orderNestID = nestId
            orderEggID = eggId
        }
        
        guard let accessToken = accessToken() else { return nil }
        
        let onBillingError: @MainActor (String, String) -> Void = { title, subtitle in
            self.handleBillingError(title, subtitle: subtitle)
        }
        
        return await createHostingOrderAPI(
            categoryPath: context.category.path,
            name: trimmed,
            packageId: context.plan.id,
            months: months,
            osId: orderOSId,
            nestId: orderNestID,
            eggId: orderEggID,
            accessToken: accessToken,
            onBillingError: onBillingError
        )
    }
    
    private func priceValue(for plan: BillingHostingPlan, currency: String?) -> Int64 {
        let code = currency?.uppercased()
        return plan.price.first { $0.currency.rawValue == code }?.price ?? plan.price.first?.price ?? 0
    }
    
    private func handleBillingError(_ title: String, subtitle: String) {
        if isInsufficientFundsError(title, subtitle: subtitle) {
            topupAlertContext = .purchase
            return
        }
        
        SystemAlert.error(title, subtitle: subtitle)
    }
}

private struct PrivateBotPackage: Decodable {
    let id: Int
    let name: String
    let locationId: Int
    let price: Int64
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
    let price: Int64
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
    let price: Int64
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

private func billingPriceList(_ price: Int64, currency: BillingCurrency) -> [BillingHostingPlanPrice] {
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
