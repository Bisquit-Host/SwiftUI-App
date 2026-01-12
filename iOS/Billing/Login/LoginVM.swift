import Foundation
import PteroNet
import BisquitoNet
import OSLog
import AuthenticationServices
@preconcurrency import DeviceCheck

@Observable
final class LoginVM {
    var isPasskeyLoading = false
    var isVerifying2FA = false
    var isSubmitting = false
    var isAttesting = false
    var attestationResult: AttestationResult?
    
    private let passkeyAuth = PasskeyAuthorizationController()
    private let baseURL = URL(string: "https://test-api.bisquit.host")!
    private let passkeyLoginPath = "auth/passkeys"
    
    var isAppAttestSupported: Bool {
        DCAppAttestService.shared.isSupported
    }
    
    func performAppAttest(userID: String? = nil) async -> AttestationResult? {
        isAttesting = true
        defer { isAttesting = false }
        
        do {
            let result = try await AppAttestService.shared.attestDevice(userID: userID)
            attestationResult = result
            return result
        } catch {
            SystemAlert.error(error.localizedDescription)
            return nil
        }
    }
    
    func login(_ login: String, _ password: String, _ captchaToken: String) async -> BillingLoginResponse? {
        isSubmitting = true
        defer { isSubmitting = false }
        
        guard let url = URL(string: "\(Endpoint.basePath)auth/signin") else {
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
            
            prettyJSON(data)
            
            return try BigAssDecoder.decode(BillingLoginResponse.self, from: data)
        } catch {
            SystemAlert.error(error.localizedDescription)
            return nil
        }
    }
    
    func signup(name: String, email: String, password: String, captchaToken: String, currency: String) async -> BillingLoginResponse? {
        let url = baseURL.appendingPathComponent("auth/signup")
        
        let body: [String: Any] = [
            "email": email.lowercased(),
            "password": password,
            "name": name,
            "captchaResponse": captchaToken,
            "currency": currency
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
                print(http.statusCode, "Sign up")
            }
            
            return try BigAssDecoder.decode(BillingLoginResponse.self, from: data)
        } catch {
            SystemAlert.error(error.localizedDescription)
            return nil
        }
    }
    
    func verify2FA(code: String, token: String) async -> BillingLoginResponse? {
        let url = baseURL.appendingPathComponent("auth/two-fa")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "code": code,
            "token": token
        ])
        
        isVerifying2FA = true
        defer { isVerifying2FA = false }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                let message = String(data: data, encoding: .utf8) ?? "Invalid response"
                SystemAlert.error(message)
                return nil
            }
            
            return try BigAssDecoder.decode(BillingLoginResponse.self, from: data)
        } catch {
            SystemAlert.error(error.localizedDescription)
            return nil
        }
    }
    
    func loginWithPasskey(_ login: String?) async -> BillingLoginResponse? {
        isPasskeyLoading = true
        defer { isPasskeyLoading = false }
        
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
            SystemAlert.error(error.localizedDescription)
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
        
        return try BigAssDecoder.decode(PasskeyOptionsResponse<PasskeyAssertionOptions>.self, from: data)
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
        
        return try BigAssDecoder.decode(BillingLoginResponse.self, from: data)
    }
}
