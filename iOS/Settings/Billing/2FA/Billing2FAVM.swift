import Foundation
import PteroNet
import BisquitoNet

@Observable
final class Billing2FAVM {
    var setup: Billing2FASetupResponse?
    var isLoading = false
    var isEnabling = false
    var isDisabling = false
    var code = ""
    
    private let baseURL = URL(string: "https://test-api.bisquit.host")!
    private let setupPath = "user/settings/two-fa"
    
    func fetchSetup() async {
        guard let accessToken = accessToken() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let url = baseURL.appendingPathComponent(setupPath)
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            try validateResponse(res, data: data)
            
            setup = try BigAssDecoder.decode(Billing2FASetupResponse.self, from: data)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func enable(code: String) async -> Bool {
        guard let accessToken = accessToken() else { return false }
        
        isEnabling = true
        defer { isEnabling = false }
        
        let url = baseURL.appendingPathComponent(setupPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["code": code])
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            try validateResponse(res, data: data)
            return true
        } catch {
            SystemAlert.error(error)
            return false
        }
    }
    
    func disable() async -> Bool {
        guard let accessToken = accessToken() else { return false }
        
        isDisabling = true
        defer { isDisabling = false }
        
        let url = baseURL.appendingPathComponent(setupPath)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            try validateResponse(res, data: data)
            return true
        } catch {
            SystemAlert.error(error)
            return false
        }
    }
}

private func validateResponse(_ response: URLResponse?, data: Data, allowedStatusCodes: Range<Int> = 200..<300) throws {
    guard let http = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard allowedStatusCodes.contains(http.statusCode) else {
        let body = String(data: data, encoding: .utf8).flatMap { $0.isEmpty ? nil : $0 }
        
        let message = body.map { "Unexpected status code \(http.statusCode): \($0)" }
        ?? "Unexpected status code \(http.statusCode)"
        
        throw NSError(
            domain: NSURLErrorDomain,
            code: URLError.badServerResponse.rawValue,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
}

extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
