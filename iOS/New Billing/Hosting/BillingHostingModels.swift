import Foundation

enum BillingHostingCategory: String, CaseIterable, Identifiable, Hashable {
    case cloud, game, bot
    
    var id: Self { self }
    var path: String { rawValue }
    
    var title: String {
        switch self {
        case .game: "Game hosting"
        case .bot: "Bot hosting"
        case .cloud: "Cloud (VDS)"
        }
    }
    
    var description: String {
        switch self {
        case .bot: "Discord, Telegram and other bots"
        case .game: "Game servers on Pterodactyl"
        case .cloud: "Virtual dedicated servers"
        }
    }
    
    var icon: String {
        switch self {
        case .bot: "bolt.horizontal.circle.fill"
        case .game: "gamecontroller.fill"
        case .cloud: "server.rack"
        }
    }
}

struct BillingHostingPlanPrice: Decodable, Equatable {
    let price: Double
    let currency: String
}

struct BillingHostingPlan: Identifiable, Decodable, Equatable {
    let id: Int
    let name: String
    let locationId: Int
    let price: [BillingHostingPlanPrice]
    let cpu: Double
    let cpuName: String?
    let memory: Double
    let memoryType: String?
    let disk: Double
    let diskType: String?
    let network: Double?
    let networkType: String?
    let nests: [Int]?
    let allocations: Int?
    let databases: Int?
    let backups: Int?
    let bonusBalanceAllowed: Bool?
    let windowsAllowed: Bool?
    let antiSpoofing: Bool?
    let whmcsLink: String?
    
    var memoryGB: Double {
        memory / 1024
    }
    
    var diskGB: Double {
        disk / 1024
    }
    
    var networkDescription: String? {
        guard let network else { return nil }
        
        if let networkType {
            return network.clean + " " + networkType
        }
        
        return "\(network.clean)"
    }
    
    static let preview = BillingHostingPlan(
        id: 1,
        name: "Game-S",
        locationId: 1,
        price: [.init(price: 399, currency: "RUB")],
        cpu: 2,
        cpuName: "Ryzen",
        memory: 4096,
        memoryType: "DDR4",
        disk: 20480,
        diskType: "NVMe",
        network: 250,
        networkType: "MBit/s",
        nests: [1, 2],
        allocations: 5,
        databases: 2,
        backups: 1,
        bonusBalanceAllowed: true,
        windowsAllowed: nil,
        antiSpoofing: nil,
        whmcsLink: nil
    )
}

struct BillingHostingLocation: Identifiable, Decodable, Equatable {
    let id: Int
    let name: String
    let flagUrl: String?
    let remarks: [String]?
    let locations: [Int]?
    let portRange: [String]?
}

struct BillingHostingPlansResponse: Decodable, Equatable {
    let packages: [BillingHostingPlan]
    let locations: [BillingHostingLocation]?
}

struct BillingHostingOrderOptions: Equatable {
    var osCategories: [BillingCloudOsCategory] = []
    var nests: [BillingHostingNest] = []
}

struct BillingHostingOrderResponse: Decodable {
    let serviceId: Int
    let amount: Double
}

struct BillingHostingNest: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
    let eggs: [BillingHostingEgg]
}

struct BillingHostingEgg: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
}

extension Double {
    var clean: String {
        let isInt = rounded() == self
        return isInt ? String(Int(self)) : String(format: "%.1f", self)
    }
}
