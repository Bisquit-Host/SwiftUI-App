import Foundation

@Observable
final class BillingTwoFAVM {
    var setup: BillingTwoFASetupResponse?
    var isLoading = false
    var isEnabling = false
    var isDisabling = false
    var error: String?
    
    private let baseURL = URL(string: "https://test-api.bisquit.host")!
    private let setupPath = "user/settings/two-fa"
    
    func fetchSetup() async {
        guard let token = ValueStore().testAccessToken.nonEmpty else {
            error = "Missing access token"
            return
        }
        
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        let url = baseURL.appendingPathComponent(setupPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            try validateResponse(response, data: data)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            setup = try decoder.decode(BillingTwoFASetupResponse.self, from: data)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func enable(code: String) async -> Bool {
        guard let token = ValueStore().testAccessToken.nonEmpty else {
            error = "Missing access token"
            return false
        }
        
        isEnabling = true
        error = nil
        
        defer { isEnabling = false }
        
        let url = baseURL.appendingPathComponent(setupPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["code": code])
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            try validateResponse(response, data: data)
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
    
    func disable() async -> Bool {
        guard let token = ValueStore().testAccessToken.nonEmpty else {
            error = "Missing access token"
            return false
        }
        
        isDisabling = true
        error = nil
        
        defer { isDisabling = false }
        
        let url = baseURL.appendingPathComponent(setupPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            try validateResponse(response, data: data)
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
}

struct BillingTwoFASetupResponse: Decodable, Equatable {
    let url: String
    let accountName: String
    let secret: String
}

private func validateResponse(_ response: URLResponse?, data: Data, allowedStatusCodes: Range<Int> = 200..<300) throws {
    guard let http = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard allowedStatusCodes.contains(http.statusCode) else {
        let body = String(data: data, encoding: .utf8).flatMap { $0.isEmpty ? nil : $0 }
        let message = body.map { "Unexpected status code \(http.statusCode): \($0)" }
        ?? "Unexpected status code \(http.statusCode)."
        
        throw NSError(
            domain: NSURLErrorDomain,
            code: URLError.badServerResponse.rawValue,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
