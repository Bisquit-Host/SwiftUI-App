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
    var composerText = ""
    var errorMessage: String?
    
    private let baseURL = "https://test-api.bisquit.host"
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
    
    private func listenToStream() async {
        guard let accessToken = accessToken() else { return }
        
        guard let url = URL(string: "\(baseURL)/support/tickets/\(ticket.id)/sse") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            isStreaming = true
            print("🔌 Opening SSE for ticket", ticket.id)
            let (bytes, _) = try await URLSession.shared.bytes(for: request)
            
            var currentEvent: String?
            var currentData = ""
            
            for try await line in bytes.lines {
                if Task.isCancelled { break }
                print("📄 SSE line:", line)
                
                if line.hasPrefix("event:") {
                    // Flush previous event if it wasn't terminated by an empty line
                    if let currentEvent, !currentData.isEmpty {
                        await handleEvent(name: currentEvent, dataString: currentData)
                        currentData = ""
                    }
                    
                    currentEvent = line.replacingOccurrences(of: "event:", with: "").trimmingCharacters(in: .whitespaces)
                    print("📡 Event:", currentEvent ?? "nil")
                    
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
            
            print("🔌 SSE closed for ticket", ticket.id)
        } catch {
            errorMessage = error.localizedDescription
            Logger().error("❌ SSE error: \(error)")
        }
        
        isStreaming = false
    }
    
    private func handleEvent(name: String?, dataString: String) async {
        guard let name else {
            print("⚠️ Empty event name")
            return
        }
        
        let trimmed = dataString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            print("⚠️ Empty event data for", name)
            return
        }
        
        print("🔍 Handling event:", name, "payload:\n", trimmed)
        
        switch name {
        case "history":
            if let data = trimmed.data(using: .utf8) {
                do {
                    let history = try BigAssDecoder.decode([SupportMessageDTO].self, from: data)
                    messages = history
                } catch {
                    print("History decode error:", error)
                    print("History payload:", trimmed)
                }
            }
            
        case "message":
            if let data = trimmed.data(using: .utf8) {
                do {
                    let message = try BigAssDecoder.decode(SupportMessageDTO.self, from: data)
                    appendMessageIfNeeded(message)
                } catch {
                    print("Message decode error:", error)
                    print("Message payload:", trimmed)
                }
            }
            
        case "ticketData":
            if let data = trimmed.data(using: .utf8),
               let newTicket = try? BigAssDecoder.decode(SupportTicketDTO.self, from: data) {
                ticket = newTicket
            }
            
        default:
            print("ℹ️ Unknown event", name, "payload:", trimmed)
        }
    }
    
    private func appendMessageIfNeeded(_ message: SupportMessageDTO) {
        guard messages.contains(where: { $0.id == message.id }) == false else { return }
        messages.append(message)
    }
}
