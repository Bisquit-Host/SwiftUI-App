import Foundation

struct GameServicePackage: Decodable, Equatable {
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
    let network: Double
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

struct BotServicePackage: Decodable, Equatable {
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
    let packageInfo: GameServicePackage
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
    let packageInfo: BotServicePackage
    let location: ServiceLocation
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price, autorenew, state, allowSuspend, allowDelete, createdAt, expiresAt, packageInfo = "package", location
    }
}

struct ChangeableGamePackage: Decodable, Identifiable, Equatable {
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
    let network: Double
    let networkType: String?
    let nests: [Int]
    let allocations: Int
    let databases: Int
    let backups: Int
    let bonusBalanceAllowed: Bool
    let whmcsLink: String?
    let enabled: Bool
    let toMinus: Double
}

struct ChangeableBotPackage: Decodable, Identifiable, Equatable {
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
    let nests: [Int]
    let allocations: Int
    let databases: Int
    let backups: Int
    let bonusBalanceAllowed: Bool
    let whmcsLink: String?
    let enabled: Bool
    let toMinus: Double
}

struct ChangeableCloudPackage: Decodable, Identifiable, Equatable {
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
    let enabled: Bool
    let toMinus: Double
}

struct ServiceRenewalResponse: Decodable, Equatable {
    let amount: Double
    let newExpiresAt: Date?
}
