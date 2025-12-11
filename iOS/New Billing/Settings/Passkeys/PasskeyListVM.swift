import Foundation
import PteroNet
import AuthenticationServices

@Observable
final class PasskeyListVM {
    var passkeys: [PasskeyListItem] = []
    var isLoading = false
    var isRegistering = false
    var error: String?
    var label = ""
    
    private let baseURL = URL(string: "https://test-api.bisquit.host")!
    private let authController = PasskeyAuthorizationController()
    private let passkeysPath = "user/settings/passkeys"
    
    func fetchPasskeys() async {
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            return
        }
        
        let url = baseURL.appendingPathComponent(passkeysPath)
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            try validateResponse(response, data: data)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let items = try decoder.decode([PasskeyListItem].self, from: data)
            
            passkeys = items
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deletePasskey(_ passkey: PasskeyListItem) async {
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            return
        }
        
        let url = baseURL.appendingPathComponent("\(passkeysPath)/\(passkey.id)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            try validateResponse(response, data: data)
            
            passkeys.removeAll {
                $0.id == passkey.id
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func registerPasskey() async {
        isRegistering = true
        error = nil
        
        defer {
            isRegistering = false
        }
        
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
            self.error = error.localizedDescription
            print("Passkey registration failed:", error.localizedDescription)
        }
    }
    
    private func startRegistration() async throws -> PasskeyOptionsResponse<PasskeyRegistrationOptions> {
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            throw PasskeyError.invalidCredential
        }
        
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
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(PasskeyOptionsResponse<PasskeyRegistrationOptions>.self, from: data)
    }
    
    private func verifyRegistration(sessionId: String, credential: [String: Any]) async throws {
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            throw PasskeyError.invalidCredential
        }
        
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
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data)
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
