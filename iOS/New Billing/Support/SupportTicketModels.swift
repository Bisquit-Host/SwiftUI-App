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
