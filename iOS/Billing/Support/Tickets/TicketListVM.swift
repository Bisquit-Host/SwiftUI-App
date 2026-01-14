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
            $0.ticket.status == .open || $0.ticket.status == .pending
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
        
        let result = await fetchTicketsAPI(showClosed: showClosed, accessToken: accessToken)
        
        if result.statusCode == 401 {
            SystemAlert.error("Unauthorized", subtitle: "401")
            return
        }
        
        if result.statusCode == 204 {
            tickets = []
            return
        }
        
        guard let data = result.data else {
            return
        }
        
        let trimmedString = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if data.isEmpty || trimmedString.isEmpty {
            tickets = []
            return
        }
        
        do {
            tickets = try BigAssDecoder.decode([SupportTicketWithLastMessageDTO].self, from: data)
        } catch {
            SystemAlert.error("Error", subtitle: error.localizedDescription)
        }
    }
    
    func createTicket(_ title: String, message: String, attachments: [PendingAttachment]) async -> Int? {
        guard let accessToken = accessToken() else { return nil }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty, !trimmedMessage.isEmpty else {
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
        
        return await createTicketAPI(
            title: trimmedTitle,
            message: trimmedMessage,
            attachments: mediaAttachments,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        )
    }
}
