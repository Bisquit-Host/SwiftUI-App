import Foundation

struct SupportTicketDTO: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let status: String
    let userId: Int
    let createdAt: String
    let updatedAt: String
}

struct SupportMessageUserDTO: Codable, Hashable {
    let name: String
    let avatar: String?
    let isSupport: Bool
}

struct SupportMessageDTO: Codable, Identifiable, Hashable {
    let id: Int
    let message: String?
    let ticketId: Int
    let userId: Int
    let media: [String]?
    let createdAt: String
    let updatedAt: String?
    let user: SupportMessageUserDTO
    
    var createdAtRelative: String {
        guard let date = Self.iso8601WithFractional.date(from: createdAt) else {
            return createdAt
        }
        
        let seconds = Int(Date().timeIntervalSince(date))
        
        if seconds < 60 {
            return "just now"
            
        } else if seconds < 3_600 {
            return "\(seconds / 60)m ago"
            
        } else if seconds < 86_400 {
            return "\(seconds / 3_600)h ago"
            
        } else if seconds < 604_800 {
            return "\(seconds / 86_400)d ago"
            
        } else if seconds < 2_592_000 {
            return "\(seconds / 604_800)w ago"
            
        } else if seconds < 31_536_000 {
            return "\(seconds / 2_592_000)m ago"
            
        } else {
            return "\(seconds / 31_536_000)y ago"
        }
    }
    
    private static let iso8601WithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return formatter
    }()
}

struct SupportTicketWithLastMessageDTO: Codable, Identifiable, Hashable {
    let ticket: SupportTicketDTO
    let lastMessage: SupportMessageDTO?
    
    var id: Int {
        ticket.id
    }
}

struct SupportTicketDataDTO: Codable, Hashable {
    let ticket: SupportTicketDTO
    let history: [SupportMessageDTO]
}

struct CreateSupportTicketResponse: Codable {
    let id: Int
}

struct CreateSupportMessageRequest: Codable {
    let message: String?
    let media: [String]?
}
