import Foundation
import BisquitoNet
import PteroNet

@Observable
final class TicketListVM {
    var tickets: [SupportTicketWithLastMessageDTO] = []
    var isLoading = false
    var showClosed = false
    var showCreateSheet = false
    var alertTooManyTickets = false
    
    func createNewTicket() {
        let totalCount = tickets.filter {
            $0.ticket.status == .new || $0.ticket.status == .awaitingUser || $0.ticket.status == .awaitingAdmin
        }.count
        
        if totalCount >= 2 {
            alertTooManyTickets = true
        } else {
            showCreateSheet = true
        }
    }
    
    func fetchTickets() async {
        guard let accessToken = accessToken() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        tickets = await fetchTicketsAPI(
            showClosed: showClosed,
            accessToken: accessToken,
            emptyResponse: [],
            onBillingError: SystemAlert.error
        ) ?? []
    }
    
    func createTicket(_ title: String, message: String, attachments: [PendingAttachment], requiresMessage: Bool = true) async -> Int? {
        guard let accessToken = accessToken() else { return nil }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty, !requiresMessage || !trimmedMessage.isEmpty else {
            SystemAlert.error("Title and message required")
            return nil
        }
        
        if attachments.count > 5 {
            SystemAlert.error("Max 5 files", subtitle: "Please remove extra attachments")
            return nil
        }
        
        if let oversized = attachments.first(where: { $0.isTooLarge }) {
            let sizeString = AttachmentLimits.readableSize(for: oversized.data.count)
            let limitString = AttachmentLimits.readableSize(for: AttachmentLimits.maxBytes)
            
            SystemAlert.error("File too large", subtitle: "\(oversized.filename) is \(sizeString). Max \(limitString) per file")
            return nil
        }
        
        let mediaAttachments = attachments.map {
            TicketMediaUpload(filename: $0.filename, contentType: $0.contentType, data: $0.data)
        }
        
        let response: CreateSupportTicketResponse? = await createTicketAPI(
            title: trimmedTitle,
            message: trimmedMessage,
            attachments: mediaAttachments,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        )
        
        return response?.id
    }
}
