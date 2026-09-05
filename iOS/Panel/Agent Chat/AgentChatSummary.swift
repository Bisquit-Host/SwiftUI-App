import Foundation
import Calagopus

struct AgentChatSummary: Identifiable, Hashable {
    var id: String { uuid }
    
    let uuid: String
    let title: String
    let hasPendingApproval: Bool
    let createdAt: Date?
    let updatedAt: Date?
    
    init?(_ json: CalagopusJSON) {
        guard let object = json.objectValue else { return nil }
        guard let uuid = object["uuid"]?.stringValue else { return nil }
        
        self.uuid = uuid
        title = object["title"]?.stringValue ?? "Agent Chat"
        hasPendingApproval = object["hasPendingApproval"]?.boolValue ?? false
        createdAt = Self.date(from: object["createdAt"]?.stringValue)
        updatedAt = Self.date(from: object["updatedAt"]?.stringValue)
    }
    
    private static func date(from value: String?) -> Date? {
        guard let value else { return nil }
        
        let timeComponent = value.split(separator: "T", maxSplits: 1).dropFirst().first
        let includesTimeZone = value.hasSuffix("Z")
            || timeComponent?.contains("+") == true
            || timeComponent?.contains("-") == true
        let normalizedValue = includesTimeZone ? value : "\(value)Z"
        
        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = fractionalFormatter.date(from: normalizedValue) {
            return date
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        return formatter.date(from: normalizedValue)
    }
}
