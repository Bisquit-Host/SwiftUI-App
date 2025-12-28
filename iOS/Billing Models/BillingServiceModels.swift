import Foundation

struct ServicePackage: Decodable, Equatable {
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

struct ServiceLocation: Decodable, Equatable {
    let id: Int
    let name: String
    let locations: [Int]?
    let portRange: [String]?
    let remarks: [String]?
    let flagUrl: String?
    let enabled: Bool?
    let inStock: Bool?
}

struct BillingGameServiceDetails: Decodable, Equatable {
    let id: Int
    var name: String
    let price: Double
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

struct BillingBotServiceDetails: Decodable, Equatable {
    let id: Int
    var name: String
    let price: Double
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

struct ChangeablePackage: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
    let locationId: Int
    let price: Double
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
    let toMinus: Double
    
    static let preview = ChangeablePackage(
        id: 101,
        name: "Starter Game Server",
        locationId: 1,
        price: 9.99,
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
        toMinus: 0.0
    )
}

struct ServiceRenewalResponse: Decodable, Equatable {
    let amount: Double
    let newExpiresAt: Date?
}
