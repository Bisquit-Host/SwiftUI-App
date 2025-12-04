import Foundation

@Observable
final class SupportTicketDetailsVM {
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
    
    func sendMessage(accessToken: String, attachments: [PendingAttachment]) async -> Bool {
        let trimmed = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || !attachments.isEmpty else { return false }
        guard !accessToken.isEmpty else { return false }
        
        if attachments.count > 5 {
            errorMessage = "Max 5 files per message."
            return false
        }
        
        isSending = true
        defer { isSending = false }
        
        var mediaPaths: [String]? = nil
        
        if !attachments.isEmpty {
            mediaPaths = await uploadMedia(accessToken: accessToken, attachments: attachments)
            
            if mediaPaths == nil {
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
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                let detail = String(data: data, encoding: .utf8) ?? ""
                errorMessage = "Failed to send (\(http.statusCode)) \(detail)"
                return false
            }
            
            let message = try JSONDecoder().decode(SupportMessageDTO.self, from: data)
            appendMessageIfNeeded(message)
            composerText = ""
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    private func listenToStream(accessToken: String) async {
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
            print("❌ SSE error:", error.localizedDescription)
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
        
        let decoder = JSONDecoder()
        print("🔍 Handling event:", name, "payload:\n", trimmed)
        
        switch name {
        case "history":
            if let data = trimmed.data(using: .utf8) {
                do {
                    let history = try decoder.decode([SupportMessageDTO].self, from: data)
                    messages = history
                } catch {
                    print("History decode error:", error)
                    print("History payload:", trimmed)
                }
            }
            
        case "message":
            if let data = trimmed.data(using: .utf8) {
                do {
                    let message = try decoder.decode(SupportMessageDTO.self, from: data)
                    appendMessageIfNeeded(message)
                } catch {
                    print("Message decode error:", error)
                    print("Message payload:", trimmed)
                }
            }
            
        case "ticketData":
            if let data = trimmed.data(using: .utf8),
               let newTicket = try? decoder.decode(SupportTicketDTO.self, from: data) {
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
    
    private func uploadMedia(accessToken: String, attachments: [PendingAttachment]) async -> [String]? {
        guard !attachments.isEmpty else { return [] }
        guard let url = URL(string: "\(baseURL)/support/tickets/\(ticket.id)/media") else { return nil }
        
        let boundary = UUID().uuidString
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        var body = Data()
        
        for file in attachments {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"\(file.filename)\"\r\n".utf8))
            body.append(Data("Content-Type: \(file.contentType)\r\n\r\n".utf8))
            body.append(file.data)
            body.append(Data("\r\n".utf8))
        }
        
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        func performUpload(using session: URLSession, request: URLRequest) async throws -> [String] {
            let (data, response) = try await session.upload(for: request, from: body)
            
            if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                let raw = String(data: data, encoding: .utf8) ?? ""
                throw UploadError.server(http.statusCode, detail: raw)
            }
            
            return try JSONDecoder().decode([String].self, from: data)
        }
        
        do {
            return try await performUpload(using: .shared, request: request)
        } catch let urlError as URLError where urlError.code == .cannotParseResponse {
            // Some networks/servers advertise HTTP/3 but respond with malformed frames.
            // Retry with a fresh session that clears Alt-Svc and disables HTTP/3 racing.
            var http2Request = request
            
            http2Request.assumesHTTP3Capable = false
            
            let config = URLSessionConfiguration.ephemeral
            var headers = config.httpAdditionalHeaders ?? [:]
            headers["Alt-Svc"] = "clear"
            config.httpAdditionalHeaders = headers
            
            let session = URLSession(configuration: config)
            
            do {
                return try await performUpload(using: session, request: http2Request)
            } catch {
                errorMessage = error.localizedDescription
                return nil
            }
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    private enum UploadError: LocalizedError {
        case server(Int, detail: String)
        
        var errorDescription: String? {
            switch self {
            case .server(let code, let detail):
                let trimmed = detail.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    return "Upload failed (\(code))"
                }
                
                return "Upload failed (\(code)) \(trimmed)"
            }
        }
    }
}
