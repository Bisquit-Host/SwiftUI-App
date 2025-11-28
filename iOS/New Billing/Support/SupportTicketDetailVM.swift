import Foundation

@Observable
final class SupportTicketDetailVM {
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
    
    init(ticket: SupportTicketDTO) {
        self.ticket = ticket
    }
    
    func start(accessToken: String) {
        guard streamTask == nil else { return }
        guard !accessToken.isEmpty else { return }
        
        streamTask = Task { [weak self] in
            await self?.listenToStream(accessToken: accessToken)
        }
    }
    
    func stop() {
        streamTask?.cancel()
        streamTask = nil
    }
    
    func sendMessage(accessToken: String) async {
        let trimmed = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !accessToken.isEmpty else { return }
        
        isSending = true
        defer { isSending = false }
        
        guard let url = URL(string: "\(baseURL)/support/tickets/\(ticket.id)/reply") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let payload = CreateSupportMessageRequest(message: trimmed, media: nil)
        request.httpBody = try? JSONEncoder().encode(payload)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                errorMessage = "Failed to send message (\(http.statusCode))"
                return
            }
            
            let message = try JSONDecoder().decode(SupportMessageDTO.self, from: data)
            appendMessageIfNeeded(message)
            composerText = ""
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func listenToStream(accessToken: String) async {
        guard let url = URL(string: "\(baseURL)/support/tickets/\(ticket.id)/sse") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            isStreaming = true
            let (bytes, _) = try await URLSession.shared.bytes(for: request)
            
            var currentEvent: String?
            var currentData = ""
            
            for try await line in bytes.lines {
                if Task.isCancelled { break }
                
                if line.hasPrefix("event:") {
                    currentEvent = line.replacingOccurrences(of: "event:", with: "").trimmingCharacters(in: .whitespaces)
                    
                } else if line.hasPrefix("data:") {
                    let dataLine = line.replacingOccurrences(of: "data:", with: "").trimmingCharacters(in: .whitespaces)
                    currentData.append(dataLine)
                    
                } else if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    await handleEvent(name: currentEvent, dataString: currentData)
                    currentEvent = nil
                    currentData = ""
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isStreaming = false
    }
    
    private func handleEvent(name: String?, dataString: String) async {
        guard let name, !dataString.isEmpty else { return }
        let decoder = JSONDecoder()
        
        switch name {
        case "history":
            if let data = dataString.data(using: .utf8),
               let history = try? decoder.decode([SupportMessageDTO].self, from: data) {
                messages = history
            }
            
        case "message":
            if let data = dataString.data(using: .utf8),
               let message = try? decoder.decode(SupportMessageDTO.self, from: data) {
                appendMessageIfNeeded(message)
            }
            
        case "ticketData":
            if let data = dataString.data(using: .utf8),
               let newTicket = try? decoder.decode(SupportTicketDTO.self, from: data) {
                ticket = newTicket
            }
            
        default:
            break
        }
    }
    
    private func appendMessageIfNeeded(_ message: SupportMessageDTO) {
        guard messages.contains(where: { $0.id == message.id }) == false else { return }
        messages.append(message)
    }
}
