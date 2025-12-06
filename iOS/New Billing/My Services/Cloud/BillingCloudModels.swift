import Foundation
import SwiftUI

enum BillingServiceState: String, Decodable {
    case installing = "INSTALLING"
    case active = "ACTIVE"
    case suspended = "SUSPENDED"
    case unsuspending = "UNSUSPENDING"
    case reinstalling = "REINSTALLING"
    case deleted = "DELETED"
    
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

struct BillingCloudSummaryLocation: Decodable, Equatable {
    let name: String
    let flagUrl: String?
}

struct BillingCloudSummaryPackage: Decodable, Equatable {
    let name: String
    let bonusBalanceAllowed: Bool?
    let windowsAllowed: Bool?
}

struct BillingCloudServiceSummary: Decodable, Identifiable, Equatable {
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
    let locationInfo: BillingCloudSummaryLocation
    let packageInfo: BillingCloudSummaryPackage
    
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
    let locationInfo: BillingCloudSummaryLocation
    let packageInfo: BillingCloudSummaryPackage
    
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
    let locationInfo: BillingCloudSummaryLocation
    let packageInfo: BillingCloudSummaryPackage
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price, autorenew, state, allowSuspend, allowDelete, createdAt, expiresAt, packageId, packageName, locationId, locationName, locationFlagUrl, locationInfo = "location", packageInfo = "package"
    }
}

struct BillingCloudPackage: Decodable, Equatable {
    let id: Int
    let name: String
    let locationId: Int
    let price: [BillingHostingPlanPrice]?
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
    let inStock: Bool?
}

struct BillingCloudLocation: Decodable, Equatable {
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

struct BillingCloudServiceDetails: Decodable, Equatable {
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
    let packageInfo: BillingCloudPackage
    let location: BillingCloudLocation
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price, autorenew, state, allowSuspend, allowDelete, createdAt, expiresAt, ip, vmId, password, system, ptrRecord, packageInfo = "package", location
    }
}

struct BillingCloudHistoryItem: Decodable, Identifiable, Equatable {
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawDate = try container.decode(String.self, forKey: .date)
        
        let parsedDate: Date? = {
            if let iso = ISO8601DateFormatter().date(from: rawDate) {
                return iso
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter.date(from: rawDate)
        }()
        
        self.init(
            id: try container.decode(Int.self, forKey: .id),
            type: try container.decode(String.self, forKey: .type),
            state: try container.decode(String.self, forKey: .state),
            date: parsedDate
        )
    }
}

struct BillingCloudOsItem: Decodable, Identifiable, Equatable {
    let id: Int
    let categoryId: Int
    let version: String?
    let vmOsId: Int
    let enabled: Bool
}

struct BillingCloudOsCategory: Decodable, Identifiable, Equatable {
    let id: Int
    let sortId: Int?
    let name: String
    let logoUrl: String?
    let enabled: Bool
    let os: [BillingCloudOsItem]
}

struct BillingCloudCharts: Decodable, Equatable {
    let cpu: [BillingCloudCpuPoint]
    let memory: [BillingCloudMemoryPoint]
    let memoryUsage: BillingCloudMemoryUsage
    let diskUsage: BillingCloudDiskUsage
    let networkInput: [BillingCloudNetworkPoint]
    let networkOutput: [BillingCloudNetworkPoint]
}

struct BillingCloudCpuPoint: Decodable, Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let cpuLoad: Double
    
    private enum CodingKeys: String, CodingKey {
        case timestamp, cpuLoad
    }
}

struct BillingCloudMemoryPoint: Decodable, Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let memoryUsage: Double
    
    private enum CodingKeys: String, CodingKey {
        case timestamp, memoryUsage
    }
}

struct BillingCloudNetworkPoint: Decodable, Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let value: Double
    
    private enum CodingKeys: String, CodingKey {
        case timestamp, value
    }
}

struct BillingCloudMemoryUsage: Decodable, Equatable {
    let usage: Double
    let free: Double
}

struct BillingCloudDiskUsage: Decodable, Equatable {
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
