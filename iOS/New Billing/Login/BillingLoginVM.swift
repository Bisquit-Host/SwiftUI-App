import AuthenticationServices
import Foundation

@Observable
final class BillingLoginVM {
    var isPasskeyLoading = false
    var passkeyError: String?
    var isVerifyingTwoFA = false
    var twoFAError: String?
    var isSubmitting = false
    
    private let passkeyAuth = PasskeyAuthorizationController()
    private let baseURL = URL(string: "https://test-api.bisquit.host")!
    private let passkeyLoginPath = "auth/passkeys"
    
    func login(_ login: String, _ password: String, _ captchaToken: String) async -> BillingLoginResponse? {
        isSubmitting = true
        
        defer {
            isSubmitting = false
        }
        
        let path = "https://test-api.bisquit.host/auth/signin"
        
        guard let url = URL(string: path) else {
            print("Invalid URL")
            return nil
        }
        
        let body = [
            "login": login.lowercased(),
            "password": password,
            "captchaResponse": captchaToken
        ]
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print(prettyString)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(BillingLoginResponse.self, from: data)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func signup(name: String, email: String, password: String, captchaToken: String) async -> BillingLoginResponse? {
        let url = baseURL.appendingPathComponent("auth/signup")
        
        let body: [String: Any] = [
            "email": email.lowercased(),
            "password": password,
            "name": name,
            "captchaResponse": captchaToken
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse {
                print("Login http code:", http.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(BillingLoginResponse.self, from: data)
        } catch {
            SystemAlert.error(error.localizedDescription)
            return nil
        }
    }
    
    func verifyTwoFA(code: String, token: String) async -> BillingLoginResponse? {
        let url = baseURL.appendingPathComponent("auth/two-fa")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "code": code,
            "token": token
        ])
        
        isVerifyingTwoFA = true
        twoFAError = nil
        
        defer { isVerifyingTwoFA = false }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                let message = String(data: data, encoding: .utf8) ?? "Invalid response"
                twoFAError = message
                return nil
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(BillingLoginResponse.self, from: data)
        } catch {
            twoFAError = error.localizedDescription
            return nil
        }
    }
    
    func loginWithPasskey(login: String?) async -> BillingLoginResponse? {
        isPasskeyLoading = true
        passkeyError = nil
        
        defer {
            isPasskeyLoading = false
        }
        
        do {
            let session = try await startPasskeyLogin(login: login)
            let request = try PasskeyRequestFactory.assertionRequest(from: session.options)
            let credential = try await passkeyAuth.perform(request)
            
            guard let assertion = credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion else {
                throw PasskeyError.invalidCredential
            }
            
            let payload = try PasskeyCredentialFormatter.assertionPayload(assertion)
            
            return try await verifyPasskeyLogin(sessionId: session.sessionId, credential: payload)
        } catch {
            passkeyError = error.localizedDescription
            
            print("Passkey login failed:", error.localizedDescription)
            return nil
        }
    }
    
    private func startPasskeyLogin(login: String?) async throws -> PasskeyOptionsResponse<PasskeyAssertionOptions> {
        let url = baseURL.appendingPathComponent("\(passkeyLoginPath)/options")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let login, !login.trimmingCharacters(in: .whitespaces).isEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["login": login])
        } else {
            request.httpBody = "{}".data(using: .utf8)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let status = (response as? HTTPURLResponse)?.statusCode, status == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(PasskeyOptionsResponse<PasskeyAssertionOptions>.self, from: data)
    }
    
    private func verifyPasskeyLogin(sessionId: String, credential: [String: Any]) async throws -> BillingLoginResponse {
        let url = baseURL.appendingPathComponent("\(passkeyLoginPath)/verify")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "sessionId": sessionId,
            "credential": credential
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let status = (response as? HTTPURLResponse)?.statusCode, status == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(BillingLoginResponse.self, from: data)
    }
}
