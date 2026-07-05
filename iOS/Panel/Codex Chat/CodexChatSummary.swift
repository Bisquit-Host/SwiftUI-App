import Foundation
import Calagopus

struct CodexChatSummary: Identifiable, Hashable {
    var id: String { uuid }
    
    let uuid: String
    let title: String
    let hasPendingApproval: Bool
    let createdAt: Date?
    let updatedAt: Date?
    
    init?(_ json: CalagopusJSON) {
        guard let object = json.objectValue else { return nil }
        guard let uuid = object["uuid"]?.stringValue ?? object["chatUuid"]?.stringValue else { return nil }
        
        self.uuid = uuid
        title = object["title"]?.stringValue ?? "Codex Chat"
        hasPendingApproval = object["hasPendingApproval"]?.boolValue ?? object["has_pending_approval"]?.boolValue ?? false
        createdAt = Self.date(from: object["createdAt"]?.stringValue ?? object["created_at"]?.stringValue)
        updatedAt = Self.date(from: object["updatedAt"]?.stringValue ?? object["updated_at"]?.stringValue)
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
