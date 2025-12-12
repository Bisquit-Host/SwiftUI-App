import Foundation

enum CloudProtectionDefaultAction: String, Codable, CaseIterable, Identifiable {
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

enum CloudProtectionProtocol: String, Codable, CaseIterable, Identifiable {
    case icmp = "ICMP",
         tcp = "TCP",
         udp = "UDP",
         gre = "GRE"
    
    var id: String { rawValue }
}

struct CloudProtectionIPInfo: Decodable, Identifiable, Equatable {
    let id: Int
    let ipv4: String
    var defaultAction: CloudProtectionDefaultAction?
}

struct CloudProtectionPreset: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
    let `protocol`: CloudProtectionProtocol
}

struct CloudProtectionProfile: Decodable, Identifiable, Equatable, Hashable {
    let id: Int
    let presetId: Int
    let presetName: String?
    let `protocol`: CloudProtectionProtocol
    let minDstPort: Int?
    let maxDstPort: Int?
    let autoCreated: Bool
    let notes: String?
}

struct CloudProtectionAttack: Decodable, Identifiable, Equatable {
    let id: String
    let createdAt: Date?
    let startedAt: Date?
    let endedAt: Date?
    let dstAddress: String?
    let sampleRate: Int?
}

struct CloudProtectionProfileInput {
    var presetId: Int
    var `protocol`: CloudProtectionProtocol
    var minPort: Int?
    var maxPort: Int?
    var notes: String?
}
