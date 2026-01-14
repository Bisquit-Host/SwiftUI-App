import Foundation
import PteroNet
import BisquitoNet
import AuthenticationServices

@Observable
final class PasskeyListVM {
    var passkeys: [PasskeyListItem] = []
    var isLoading = false
    var isRegistering = false
    var label = ""
    
    private let baseURL = URL(string: "https://test-api.bisquit.host")!
    private let authController = PasskeyAuthorizationController()
    private let passkeysPath = "user/settings/passkeys"
    
    func fetchPasskeys() async {
        guard let accessToken = accessToken() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let url = baseURL.appendingPathComponent(passkeysPath)
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            try validateResponse(res, data: data)
            
            passkeys = try BigAssDecoder.decode([PasskeyListItem].self, from: data)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deletePasskey(_ passkey: PasskeyListItem) async {
        guard let accessToken = accessToken() else { return }
        
        let url = baseURL.appendingPathComponent("\(passkeysPath)/\(passkey.id)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            try validateResponse(res, data: data)
            
            passkeys.removeAll {
                $0.id == passkey.id
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func registerPasskey() async {
        isRegistering = true
        defer { isRegistering = false }
        
        do {
            let session = try await startRegistration()
            let request = try PasskeyRequestFactory.registrationRequest(from: session.options)
            let credential = try await authController.perform(request)
            
            guard let registration = credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration else {
                throw PasskeyError.invalidCredential
            }
            
            let payload = try PasskeyCredentialFormatter.attestationPayload(registration)
            
            try await verifyRegistration(sessionId: session.sessionId, credential: payload)
            
            label = ""
            
            await fetchPasskeys()
        } catch {
            SystemAlert.error(error)
            print("Passkey registration failed:", error)
        }
    }
    
    private func startRegistration() async throws -> PasskeyOptionsResponse<PasskeyRegistrationOptions> {
        guard let accessToken = accessToken() else { throw PasskeyError.invalidCredential }
        
        let url = baseURL.appendingPathComponent("\(passkeysPath)/register/options")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        if let label = label.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["label": label])
        } else {
            request.httpBody = "{}".data(using: .utf8)
        }
        
        let (data, res) = try await URLSession.shared.data(for: request)
        try validateResponse(res, data: data)
        
        return try BigAssDecoder.decode(PasskeyOptionsResponse<PasskeyRegistrationOptions>.self, from: data)
    }
    
    private func verifyRegistration(sessionId: String, credential: [String: Any]) async throws {
        guard let accessToken = accessToken() else { throw PasskeyError.invalidCredential }
        
        let url = baseURL.appendingPathComponent("\(passkeysPath)/register/verify")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "sessionId": sessionId,
            "credential": credential
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, res) = try await URLSession.shared.data(for: request)
        try validateResponse(res, data: data)
    }
}

private func validateResponse(_ response: URLResponse?, data: Data, allowedStatusCodes: Range<Int> = 200..<300) throws {
    guard let http = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard allowedStatusCodes.contains(http.statusCode) else {
        let body = String(data: data, encoding: .utf8).flatMap {
            $0.isEmpty ? nil : $0
        }
        
        let message = body.map {
            "Unexpected status code \(http.statusCode): \($0)"
        }
        
        ?? "Unexpected status code \(http.statusCode)"
        
        throw NSError(
            domain: NSURLErrorDomain,
            code: URLError.badServerResponse.rawValue,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
}
