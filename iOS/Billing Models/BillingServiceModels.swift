import Foundation

nonisolated struct ServicePackage: Decodable, Equatable, Sendable {
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
    let nests: [Int]
    let allocations: Int
    let databases: Int
    let backups: Int
    let bonusBalanceAllowed: Bool
    let whmcsLink: String?
    let enabled: Bool
    let inStock: Bool?
}

nonisolated struct ServiceLocation: Decodable, Equatable, Sendable {
    let id: Int
    let name: String
    let locations: [Int]?
    let portRange: [String]?
    let remarks: [String]?
    let flagUrl: String?
    let enabled: Bool?
    let inStock: Bool?
}

nonisolated struct BillingServiceDetails: Decodable, Equatable, Sendable {
    let id: Int
    var name: String
    let price: Int64
    var autorenew: Bool
    let state: BillingServiceState
    let allowSuspend: Bool
    let allowDelete: Bool
    let createdAt: Date?
    var expiresAt: Date?
    let packageInfo: ServicePackage
    let location: ServiceLocation
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price, autorenew, state, allowSuspend, allowDelete, createdAt, expiresAt, packageInfo = "package", location
    }
}

nonisolated struct ChangeablePackage: Decodable, Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let locationId: Int
    let price: Int64
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
    let windowsAllowed: Bool?
    let antiSpoofing: Bool?
    let bonusBalanceAllowed: Bool
    let whmcsLink: String?
    let enabled: Bool
    let toMinus: Int64
    
    var amountDueNow: Int64 {
        max(toMinus, 0)
    }
    
    static let preview = ChangeablePackage(
        id: 101,
        name: "Starter Game Server",
        locationId: 1,
        price: 999,
        cpu: 2.0,
        cpuName: "vCPU",
        memory: 4096,
        memoryType: "DDR4",
        disk: 50,
        diskType: "NVMe",
        network: 1.0,
        networkType: "Gbps",
        nests: [1, 2, 3],
        allocations: 2,
        databases: 1,
        backups: 3,
        windowsAllowed: nil,
        antiSpoofing: nil,
        bonusBalanceAllowed: true,
        whmcsLink: nil,
        enabled: true,
        toMinus: 499
    )
}

nonisolated struct ServiceRenewalResponse: Decodable, Equatable, Sendable {
    let amount: Int64
    let newExpiresAt: Date?
}
