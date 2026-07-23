import Foundation
import BisquitoNet
import Calagopus

@Observable
final class TicketDetailsVM {
    var ticket: SupportTicketDTO
    
    init(_ ticket: SupportTicketDTO) {
        self.ticket = ticket
    }
    
    var messages: [SupportMessageDTO] = []
    var isStreaming = false
    var isSending = false
    var isClosing = false
    var deletingMessageIds: Set<Int> = []
    var composerText = ""
    var errorMessage: String?
    
    private var streamTask: Task<Void, Never>?
    
    func start() {
        guard streamTask == nil else { return }
        
        streamTask = Task { [weak self] in
            await self?.listenToStream()
        }
    }
    
    func stop() {
        streamTask?.cancel()
        streamTask = nil
    }
    
    func sendMessage(attachments: [PendingAttachment]) async -> Bool {
        guard let accessToken = accessToken() else { return false }
        guard ticket.status != .closed else { return false }
        
        let trimmed = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || !attachments.isEmpty else { return false }
        
        if attachments.count > 5 {
            errorMessage = "Max 5 files per message"
            return false
        }
        
        if let oversized = attachments.first(where: { $0.isTooLarge }) {
            let sizeString = AttachmentLimits.readableSize(for: oversized.data.count)
            let limitString = AttachmentLimits.readableSize(for: AttachmentLimits.maxBytes)
            
            let message = "\(oversized.filename) is \(sizeString). Max \(limitString) per file"
            errorMessage = "File too large. " + message
            SystemAlert.error("File too large", subtitle: message)
            
            return false
        }
        
        isSending = true
        defer { isSending = false }
        
        var mediaPaths: [String]? = nil
        
        if !attachments.isEmpty {
            let mediaAttachments = attachments.map {
                TicketMediaUpload(filename: $0.filename, contentType: $0.contentType, data: $0.data)
            }
            
            mediaPaths = await uploadTicketMediaAPI(
                ticketId: ticket.id,
                attachments: mediaAttachments,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            )
            
            if mediaPaths == nil {
                errorMessage = "Failed to upload attachments"
                return false
            }
        }
        
        guard let message = await replyToTicketAPI(
            ticketId: ticket.id,
            message: trimmed.isEmpty ? nil : trimmed,
            media: mediaPaths,
            accessToken: accessToken,
            onBillingError: handleBillingError
        ) else {
            return false
        }

        appendMessageIfNeeded(message)
        composerText = ""
        errorMessage = nil
        return true
    }
    
    func closeTicket() async -> Bool {
        guard let accessToken = accessToken() else { return false }
        guard ticket.status != .closed, !isClosing else { return false }
        
        isClosing = true
        defer { isClosing = false }
        
        let response: CloseSupportTicketResponse? = await closeTicketAPI(
            ticketId: ticket.id,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        )
        
        guard response?.ok == true else { return false }
        
        ticket = SupportTicketDTO(
            id: ticket.id,
            title: ticket.title,
            status: .closed,
            userId: ticket.userId,
            createdAt: ticket.createdAt,
            updatedAt: Date()
        )
        
        errorMessage = nil
        return true
    }
    
    func isDeletingMessage(_ messageId: Int) -> Bool {
        deletingMessageIds.contains(messageId)
    }
    
    func deleteMessage(_ message: SupportMessageDTO) async -> Bool {
        guard let accessToken = accessToken() else { return false }
        guard message.userId == ticket.userId else { return false }
        guard deletingMessageIds.contains(message.id) == false else { return false }
        
        deletingMessageIds.insert(message.id)
        defer {
            deletingMessageIds.remove(message.id)
        }
        
        guard await deleteTicketMessageAPI(
            ticketId: ticket.id,
            messageId: message.id,
            accessToken: accessToken,
            onBillingError: handleBillingError
        ) else {
            return false
        }
        
        removeMessage(message.id)
        errorMessage = nil
        return true
    }
    
    private func listenToStream() async {
        guard let accessToken = accessToken() else { return }

        isStreaming = true
        defer { isStreaming = false }

        do {
            Logger().info("🔌 Opening SSE for ticket \(self.ticket.id)")

            for try await event in ticketEventsAPI(ticketId: ticket.id, accessToken: accessToken) {
                handleEvent(event)
            }

            Logger().info("🔌 SSE closed for ticket \(self.ticket.id)")
        } catch {
            errorMessage = error.localizedDescription
            Logger().error("SSE error: \(error)")
        }
    }

    private func handleEvent(_ event: SupportTicketEvent) {
        switch event {
        case .history(let history):
            messages = history
        case .message(let message):
            appendMessageIfNeeded(message)
        case .messageDeleted(let messageId):
            removeMessage(messageId)
        case .ticketData(let ticket):
            self.ticket = ticket
        case .unknown(let name, let payload):
            Logger().warning("Unknown event \(name) payload: \(payload)")
        }
    }
    
    private func appendMessageIfNeeded(_ message: SupportMessageDTO) {
        guard messages.contains(where: { $0.id == message.id }) == false else { return }
        messages.append(message)
    }
    
    private func removeMessage(_ messageId: Int) {
        messages.removeAll { $0.id == messageId }
    }
    
    private func handleBillingError(_ title: String, _ subtitle: String?) {
        errorMessage = subtitle ?? title
        SystemAlert.error(title, subtitle: subtitle)
    }
}
