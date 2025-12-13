import Foundation
import SwiftUI

enum BillingServiceState: String, Decodable {
    case installing = "INSTALLING",
         active = "ACTIVE",
         suspended = "SUSPENDED",
         unsuspending = "UNSUSPENDING",
         reinstalling = "REINSTALLING",
         deleted = "DELETED"
    
    var title: String {
        rawValue.lowercased().capitalized
    }
    
    var color: Color {
        switch self {
        case .active: .green
        case .installing, .unsuspending, .reinstalling: .orange
        case .suspended: .red
        case .deleted: .gray
        }
    }
}

struct ServiceLocationSummary: Decodable, Equatable {
    let name: String
    let flagUrl: String?
}

struct ServiceSummaryPackage: Decodable, Equatable {
    let name: String
    let bonusBalanceAllowed: Bool?
    let windowsAllowed: Bool?
}

struct CloudServiceSummary: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
    let price: Double
    let autorenew: Bool
    let state: BillingServiceState
    let allowSuspend: Bool
    let allowDelete: Bool
    let createdAt: Date?
    let expiresAt: Date?
    let packageId: Int
    let packageName: String
    let locationId: Int
    let locationName: String
    let locationFlagUrl: String?
    let system: String?
    let ip: String?
    let locationInfo: ServiceLocationSummary
    let packageInfo: ServiceSummaryPackage
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price, autorenew, state, allowSuspend, allowDelete, createdAt, expiresAt, packageId, packageName, locationId, locationName, locationFlagUrl, system, ip, locationInfo = "location", packageInfo = "package"
    }
}

// MARK: - Game & Bot summaries

struct BillingGameServiceSummary: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
    let price: Double
    let autorenew: Bool
    let state: BillingServiceState
    let allowSuspend: Bool
    let allowDelete: Bool
    let createdAt: Date?
    let expiresAt: Date?
    let packageId: Int
    let packageName: String
    let locationId: Int
    let locationName: String
    let locationFlagUrl: String?
    let locationInfo: ServiceLocationSummary
    let packageInfo: ServiceSummaryPackage
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price, autorenew, state, allowSuspend, allowDelete, createdAt, expiresAt, packageId, packageName, locationId, locationName, locationFlagUrl, locationInfo = "location", packageInfo = "package"
    }
}

struct BillingBotServiceSummary: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
    let price: Double
    let autorenew: Bool
    let state: BillingServiceState
    let allowSuspend: Bool
    let allowDelete: Bool
    let createdAt: Date?
    let expiresAt: Date?
    let packageId: Int
    let packageName: String
    let locationId: Int
    let locationName: String
    let locationFlagUrl: String?
    let locationInfo: ServiceLocationSummary
    let packageInfo: ServiceSummaryPackage
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price, autorenew, state, allowSuspend, allowDelete, createdAt, expiresAt, packageId, packageName, locationId, locationName, locationFlagUrl, locationInfo = "location", packageInfo = "package"
    }
}

struct CloudServicePackage: Decodable, Equatable {
    let id: Int
    let name: String
    let locationId: Int
    let price: [BillingHostingPlanPrice]?
    let cpu: Double
    let cpuName: String?
    
    /// MB
    let memory: Double
    
    /// MB
    let disk: Double
    
    let diskType: String?
    let network: Double
    let networkType: String?
    let bonusBalanceAllowed: Bool
    let windowsAllowed: Bool
    let antiSpoofing: Bool
    let whmcsLink: String?
    let enabled: Bool
    let inStock: Bool?
}

struct CloudServiceLocation: Decodable, Equatable {
    let id: Int
    let name: String
    let flagUrl: String?
    let remarks: [String]?
    let enabled: Bool
    let inStock: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, flagUrl, remarks, enabled, inStock
    }
    
    init(id: Int, name: String, flagUrl: String?, remarks: [String]?, enabled: Bool, inStock: Bool?) {
        self.id = id
        self.name = name
        self.flagUrl = flagUrl
        self.remarks = remarks
        self.enabled = enabled
        self.inStock = inStock
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let remarksValue: [String]? = {
            if let array = try? container.decodeIfPresent([String].self, forKey: .remarks) {
                return array
            }
            if let single = try? container.decodeIfPresent(String.self, forKey: .remarks) {
                return [single]
            }
            return nil
        }()
        
        self.init(
            id: try container.decode(Int.self, forKey: .id),
            name: try container.decode(String.self, forKey: .name),
            flagUrl: try container.decodeIfPresent(String.self, forKey: .flagUrl),
            remarks: remarksValue,
            enabled: try container.decode(Bool.self, forKey: .enabled),
            inStock: try container.decodeIfPresent(Bool.self, forKey: .inStock)
        )
    }
}

struct CloudServiceDetails: Decodable, Equatable {
    let id: Int
    var name: String
    let price: Double
    var autorenew: Bool
    let state: BillingServiceState
    let allowSuspend: Bool
    let allowDelete: Bool
    let createdAt: Date?
    var expiresAt: Date?
    let ip: String?
    let vmId: Int?
    let password: String?
    let system: String?
    let ptrRecord: String?
    let packageInfo: CloudServicePackage
    let location: CloudServiceLocation
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price, autorenew, state, allowSuspend, allowDelete, createdAt, expiresAt, ip, vmId, password, system, ptrRecord, packageInfo = "package", location
    }
}

struct CloudServiceHistoryItem: Decodable, Identifiable, Equatable {
    let id: Int
    let type: String
    let state: String
    let date: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id, type, state, date
    }
    
    init(id: Int, type: String, state: String, date: Date?) {
        self.id = id
        self.type = type
        self.state = state
        self.date = date
    }
}

struct CloudServiceOSItem: Decodable, Identifiable, Equatable {
    let id: Int
    let categoryId: Int
    let version: String?
    let vmOsId: Int
    let enabled: Bool
}

struct CloudServiceOSCategory: Decodable, Identifiable, Equatable {
    let id: Int
    let sortId: Int?
    let name: String
    let logoUrl: String?
    let enabled: Bool
    let os: [CloudServiceOSItem]
}

struct CloudServiceCharts: Decodable, Equatable {
    let cpu: [CloudServiceCPUPoint]
    let memory: [CloudServiceMemoryPoint]
    let memoryUsage: CloudServiceMemoryUsage
    let diskUsage: CloudServiceDiskUsage
    let networkInput: [CloudServiceNetworkPoint]
    let networkOutput: [CloudServiceNetworkPoint]
}

struct CloudServiceCPUPoint: Decodable, Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let cpuLoad: Double
    
    private enum CodingKeys: String, CodingKey {
        case timestamp, cpuLoad
    }
}

struct CloudServiceMemoryPoint: Decodable, Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let memoryUsage: Double
    
    private enum CodingKeys: String, CodingKey {
        case timestamp, memoryUsage
    }
}

struct CloudServiceNetworkPoint: Decodable, Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let value: Double
    
    private enum CodingKeys: String, CodingKey {
        case timestamp, value
    }
}

struct CloudServiceMemoryUsage: Decodable, Equatable {
    let usage: Double
    let free: Double
}

struct CloudServiceDiskUsage: Decodable, Equatable {
    let usage: Double
    let free: Double
}

private extension DateFormatter {
    static let utc: DateFormatter = {
        let f = DateFormatter()
        f.timeZone = TimeZone(secondsFromGMT: 0)
        
        return f
    }()
}
