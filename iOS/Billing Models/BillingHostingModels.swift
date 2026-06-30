import Foundation
import SwiftUI
import BisquitoNet

nonisolated enum BillingHostingCategory: String, CaseIterable, Identifiable, Hashable, Sendable {
    case cloud, game, bot
    
    var id: Self { self }
    var path: String { rawValue }
    
    var title: LocalizedStringKey {
        switch self {
        case .game: "Game hosting"
        case .bot: "Bot hosting"
        case .cloud: "Cloud (VDS)"
        }
    }
    
    var description: LocalizedStringKey {
        switch self {
        case .bot: "Discord, Telegram and other bots"
        case .game: "Game servers on Calagopus"
        case .cloud: "Virtual dedicated servers"
        }
    }
    
    var tint: Color {
        switch self {
        case .cloud: .orange
        case .game: .indigo
        case .bot: .green
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

nonisolated struct BillingHostingPlanPrice: Decodable, Equatable, Sendable {
    let price: Int64
    let currency: BillingCurrency
    
    init(price: Int64, currency: BillingCurrency) {
        self.price = price
        self.currency = currency
    }
    
    private enum CodingKeys: String, CodingKey {
        case price
        case currency
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currency = try container.decode(BillingCurrency.self, forKey: .currency)
        
        if let intValue = try? container.decode(Int64.self, forKey: .price) {
            price = intValue
            return
        }
        
        if let doubleValue = try? container.decode(Double.self, forKey: .price) {
            let scaled = Decimal(doubleValue) * Decimal(currency.scale)
            var rounded = Decimal()
            var value = scaled
            NSDecimalRound(&rounded, &value, 0, .plain)
            price = NSDecimalNumber(decimal: rounded).int64Value
            return
        }
        
        price = 0
    }
}

nonisolated struct BillingHostingPlan: Identifiable, Decodable, Equatable, Sendable {
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
        price: [.init(price: 39_900, currency: .RUB)],
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

nonisolated struct HostingLocation: Identifiable, Decodable, Equatable, Sendable {
    let id: Int
    let name: String
    let flagUrl: String?
    let remarks: [String]?
    let locations: [String]?
    let portRange: [String]?
}

nonisolated struct BillingHostingPlansResponse: Decodable, Equatable, Sendable {
    let packages: [BillingHostingPlan]
    let locations: [HostingLocation]?
}

nonisolated struct BillingHostingOrderOptions: Equatable, Sendable {
    var osCategories: [CloudServiceOSCategory] = []
    var nests: [BillingHostingNest] = []
}

nonisolated struct BillingHostingOrderResponse: Decodable, Sendable {
    let serviceId: Int
    let amount: Int64
}

nonisolated struct BillingHostingNest: Decodable, Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let eggs: [BillingHostingEgg]
}

nonisolated struct BillingHostingEgg: Decodable, Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
}

extension Double {
    nonisolated var clean: String {
        let isInt = rounded() == self
        return isInt ? String(Int(self)) : self.formatted(.fractionDigits(1))
    }
}
