import Foundation
import PteroNet

@Observable
final class TicketListVM {
    var tickets: [SupportTicketWithLastMessageDTO] = []
    var isLoading = false
    var showClosed = false
    var showCreateSheet = false
    var alertTooManyTickets = false
    
    private let baseURL = "https://test-api.bisquit.host"
    
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
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        var components = URLComponents(string: "\(baseURL)/support/tickets")
        
        if showClosed {
            components?.queryItems = [URLQueryItem(name: "showClosed", value: "1")]
        }
        
        guard let url = components?.url else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse {
                print("Response code", http.statusCode)
                
                if http.statusCode == 401 {
                    SystemAlert.error("Unauthorized", subtitle: "401")
                    return
                }
                
                if http.statusCode == 204 {
                    tickets = []
                    return
                }
            }
            
            let trimmedString = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            if data.isEmpty || trimmedString.isEmpty {
                tickets = []
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: pretty, encoding: .utf8) {
                print("Support tickets response:\\n\(prettyString)")
            } else if let raw = String(data: data, encoding: .utf8) {
                print("Support tickets raw response:\\n\(raw)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            tickets = try decoder.decode([SupportTicketWithLastMessageDTO].self, from: data)
        } catch {
            print("❌", error.localizedDescription)
            SystemAlert.error("Error", subtitle: error.localizedDescription)
        }
    }
    
    func createTicket(title: String, message: String, attachments: [PendingAttachment]) async -> Int? {
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            return nil
        }
        
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
            
            SystemAlert.error("File too large", subtitle: "\(oversized.filename) is \(sizeString). Max \(limitString) per file.")
            return nil
        }
        
        let boundary = UUID().uuidString
        guard let url = URL(string: "\(baseURL)/support/tickets") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        var body = Data()
        
        func appendField(_ name: String, value: String) {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".utf8))
            body.append(Data("\(value)\r\n".utf8))
        }
        
        appendField("title", value: trimmedTitle)
        appendField("message", value: trimmedMessage)
        
        for file in attachments {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"\(file.filename)\"\r\n".utf8))
            body.append(Data("Content-Type: \(file.contentType)\r\n\r\n".utf8))
            body.append(file.data)
            body.append(Data("\r\n".utf8))
        }
        
        if let closingData = "--\(boundary)--\r\n".data(using: .utf8) {
            body.append(closingData)
        }
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse {
                if http.statusCode >= 400 {
                    if let raw = String(data: data, encoding: .utf8) {
                        print("Create ticket failed \(http.statusCode): \(raw)")
                    }
                    SystemAlert.error("Failed to create ticket", subtitle: http.statusCode.description)
                    return nil
                }
                
                print("Create ticket status", http.statusCode)
            }
            
            let created = try JSONDecoder().decode(CreateSupportTicketResponse.self, from: data)
            return created.id
        } catch {
            SystemAlert.error("Error", subtitle: error.localizedDescription)
            return nil
        }
    }
}
