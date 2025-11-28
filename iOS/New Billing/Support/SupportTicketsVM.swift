import Foundation

@Observable
final class SupportTicketsVM {
    var tickets: [SupportTicketWithLastMessageDTO] = []
    var isLoading = false
    var showClosed = false
    
    private let baseURL = "https://test-api.bisquit.host"
    
    func loadTickets(accessToken: String) async {
        guard !accessToken.isEmpty else {
            print("No access token")
            return
        }
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
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
            
            tickets = try JSONDecoder().decode([SupportTicketWithLastMessageDTO].self, from: data)
        } catch {
            print("❌", error.localizedDescription)
            SystemAlert.error("Error", subtitle: error.localizedDescription)
        }
    }
    
    func createTicket(accessToken: String, title: String, message: String) async -> Int? {
        guard !accessToken.isEmpty else { return nil }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty, !trimmedMessage.isEmpty else {
            SystemAlert.error("Title and message required", subtitle: nil)
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
