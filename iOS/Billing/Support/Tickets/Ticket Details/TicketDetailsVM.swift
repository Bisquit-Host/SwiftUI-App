import Foundation
import BisquitoNet
import PteroNet

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
    
    private let baseURL = "https://api.bisquit.host"
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
        
        guard let url = URL(string: "\(baseURL)/support/tickets/\(ticket.id)/reply") else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let payload = CreateSupportMessageRequest(message: trimmed.isEmpty ? nil : trimmed, media: mediaPaths)
        request.httpBody = try? JSONEncoder().encode(payload)
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            
            if decodeBillingError(data, with: res, onDecode: SystemAlert.error) {
                return false
            }
            
            let message = try BigAssDecoder.decode(SupportMessageDTO.self, from: data)
            appendMessageIfNeeded(message)
            composerText = ""
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
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
        
        guard await deleteTicketMessage(message.id, accessToken: accessToken) else { return false }
        
        removeMessage(message.id)
        errorMessage = nil
        return true
    }
    
    private func listenToStream() async {
        guard let accessToken = accessToken() else { return }
        
        guard let url = URL(string: "\(baseURL)/support/tickets/\(ticket.id)/sse") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            isStreaming = true
            Logger().info("🔌 Opening SSE for ticket \(self.ticket.id)")
            let (bytes, _) = try await URLSession.shared.bytes(for: request)
            
            var currentEvent: String?
            var currentData = ""
            
            for try await line in bytes.lines {
                if Task.isCancelled { break }
                Logger().info("📄 SSE line: \(line)")
                
                if line.hasPrefix("event:") {
                    // Flush previous event if it wasn't terminated by an empty line
                    if let currentEvent, !currentData.isEmpty {
                        await handleEvent(name: currentEvent, dataString: currentData)
                        currentData = ""
                    }
                    
                    currentEvent = line.replacingOccurrences(of: "event:", with: "").trimmingCharacters(in: .whitespaces)
                    Logger().info("📡 Event: \(currentEvent ?? "nil")")
                    
                } else if line.hasPrefix("data:") {
                    let dataLine = line.replacingOccurrences(of: "data:", with: "").trimmingCharacters(in: .whitespaces)
                    currentData.append(dataLine)
                    currentData.append("\n")
                    
                } else if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    await handleEvent(name: currentEvent, dataString: currentData)
                    currentEvent = nil
                    currentData = ""
                }
            }
            
            // Flush if stream ended without a trailing newline
            if let currentEvent, !currentData.isEmpty {
                await handleEvent(name: currentEvent, dataString: currentData)
            }
            
            Logger().info("🔌 SSE closed for ticket \(self.ticket.id)")
        } catch {
            errorMessage = error.localizedDescription
            Logger().error("SSE error: \(error)")
        }
        
        isStreaming = false
    }
    
    private func handleEvent(name: String?, dataString: String) async {
        guard let name else {
            Logger().warning("Empty event name")
            return
        }
        
        let trimmed = dataString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            Logger().warning("Empty event data for \(name)")
            return
        }
        
        Logger().info("🔍 Handling event: \(name), payload:\n\(trimmed)")
        
        switch name {
        case "history":
            if let data = trimmed.data(using: .utf8) {
                do {
                    let history = try BigAssDecoder.decode([SupportMessageDTO].self, from: data)
                    messages = history
                } catch {
                    Logger().error("History decode error: \(error)")
                    Logger().info("History payload: \(trimmed)")
                }
            }
            
        case "message":
            if let data = trimmed.data(using: .utf8) {
                do {
                    let message = try BigAssDecoder.decode(SupportMessageDTO.self, from: data)
                    appendMessageIfNeeded(message)
                } catch {
                    Logger().error("Message decode error: \(error)")
                    Logger().info("Message payload: \(trimmed)")
                }
            }
            
        case "messageDeleted", "messageDelete", "deleteMessage", "deletedMessage":
            if let messageId = deletedMessageId(from: trimmed) {
                removeMessage(messageId)
            } else {
                Logger().warning("Message deletion payload decode error: \(trimmed)")
            }
            
        case "ticketData":
            if let data = trimmed.data(using: .utf8),
               let newTicket = try? BigAssDecoder.decode(SupportTicketDTO.self, from: data) {
                ticket = newTicket
            }
            
        default:
            Logger().warning("Unknown event \(name) payload: \(trimmed)")
        }
    }
    
    private func appendMessageIfNeeded(_ message: SupportMessageDTO) {
        guard messages.contains(where: { $0.id == message.id }) == false else { return }
        messages.append(message)
    }
    
    private func removeMessage(_ messageId: Int) {
        messages.removeAll { $0.id == messageId }
    }
    
    private func deleteTicketMessage(_ messageId: Int, accessToken: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/support/tickets/\(ticket.id)/messages/\(messageId)") else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            
            if decodeBillingError(data, with: res, onDecode: SystemAlert.error) {
                return false
            }
            
            guard let http = res as? HTTPURLResponse else {
                errorMessage = "No response"
                SystemAlert.error("No response")
                return false
            }
            
            guard (200...299).contains(http.statusCode) else {
                let raw = String(data: data, encoding: .utf8) ?? ""
                let subtitle = raw.isEmpty ? http.statusCode.description : raw
                
                errorMessage = subtitle
                SystemAlert.error("Failed to delete message", subtitle: subtitle)
                return false
            }
            
            return true
        } catch {
            errorMessage = error.localizedDescription
            SystemAlert.error("Failed to delete message", subtitle: error.localizedDescription)
            return false
        }
    }
    
    private func deletedMessageId(from payload: String) -> Int? {
        if let id = Int(payload) {
            return id
        }
        
        guard let data = payload.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        
        if let dictionary = object as? [String: Any] {
            return dictionary["id"] as? Int ?? dictionary["messageId"] as? Int
        }
        
        return nil
    }
}
