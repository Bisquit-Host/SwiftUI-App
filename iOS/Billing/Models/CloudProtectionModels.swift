import Foundation

enum VDSProtectionDefaultAction: String, Codable, CaseIterable, Identifiable {
    case accept = "ACCEPT",
         filter = "FILTER",
         drop = "DROP"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .accept: "Accept"
        case .filter: "Filter"
        case .drop: "Drop"
        }
    }
    
    var isUpdatable: Bool {
        self == .filter || self == .drop
    }
}

enum VDSProtectionProtocol: String, Codable, CaseIterable, Identifiable {
    case icmp = "ICMP",
         tcp = "TCP",
         udp = "UDP",
         gre = "GRE"
    
    var id: String { rawValue }
}

struct VDSProtectionIPInfo: Decodable, Identifiable, Equatable {
    let id: Int
    let ipv4: String
    var defaultAction: VDSProtectionDefaultAction?
}

struct VDSProtectionPreset: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
    let `protocol`: VDSProtectionProtocol
}

struct VDSProtectionProfile: Decodable, Identifiable, Equatable, Hashable {
    let id: Int
    let presetId: Int
    let presetName: String?
    let `protocol`: VDSProtectionProtocol
    let minDstPort: Int?
    let maxDstPort: Int?
    let autoCreated: Bool
    let notes: String?
}

struct VDSProtectionAttack: Decodable, Identifiable, Equatable {
    let id: String
    let createdAt: Date?
    let startedAt: Date?
    let endedAt: Date?
    let dstAddress: String?
    let sampleRate: Int?
}

struct VDSProtectionProfileInput {
    var presetId: Int
    var `protocol`: VDSProtectionProtocol
    var minPort: Int?
    var maxPort: Int?
    var notes: String?
}
