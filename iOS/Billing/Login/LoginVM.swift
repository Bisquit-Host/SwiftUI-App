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
    var selectedCurrency: BillingCurrency = .RUB
    
    private let passkeyAuth = PasskeyAuthorizationController()
    private let baseURL = URL(string: Endpoint.basePath)!
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
            SystemAlert.error(error)
            return nil
        }
    }
    
    func login(_ login: String, _ password: String, captchaToken: String? = nil, attestResponse: AttestationResult? = nil) async -> BillingLoginResponse? {
        isSubmitting = true
        defer { isSubmitting = false }
        
        guard let url = URL(string: "\(Endpoint.basePath)auth/signin") else {
            Logger().error("Invalid URL")
            return nil
        }
        
        var body: [String: Any] = [
            "login": login.lowercased(),
            "password": password
        ]
        
        if let attestResponse {
            body["attestResponse"] = [
                "challenge": attestResponse.challenge,
                "attestation": attestResponse.attestation,
                "keyID": attestResponse.keyID
            ]
        } else if let captchaToken {
            body["captchaResponse"] = captchaToken
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, res) = try await URLSession.shared.data(for: req)
            prettyJSON(data)
            
            if decodeBillingError(data, with: res, onDecode: SystemAlert.error) {
                return nil
            }
            
            return try BigAssDecoder.decode(BillingLoginResponse.self, from: data)
        } catch {
            SystemAlert.error(error)
            return nil
        }
    }
    
    func signup(name: String, email: String, password: String, captchaToken: String? = nil, attestResponse: AttestationResult? = nil) async -> BillingLoginResponse? {
        let url = baseURL.appendingPathComponent("auth/signup")
        
        var body: [String: Any] = [
            "email": email.lowercased(),
            "password": password,
            "name": name,
            "currency": selectedCurrency.rawValue
        ]
        
        if let attestResponse {
            body["attestResponse"] = [
                "challenge": attestResponse.challenge,
                "attestation": attestResponse.attestation,
                "keyID": attestResponse.keyID
            ]
        } else if let captchaToken {
            body["captchaResponse"] = captchaToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            
            if let http = res as? HTTPURLResponse {
                Logger().info("\(http.statusCode) • Sign up")
            }
            
            return try BigAssDecoder.decode(BillingLoginResponse.self, from: data)
        } catch {
            SystemAlert.error(error)
            return nil
        }
    }
    
    func verify2FA(code: String, token: String) async -> BillingLoginResponse? {
        isVerifying2FA = true
        defer { isVerifying2FA = false }
        
        return await verify2FAAPI(code: code, token: token, onBillingError: { @MainActor title, subtitle in
            SystemAlert.error(title, subtitle: subtitle)
        })
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
            SystemAlert.error(error)
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
        
        let (data, res) = try await URLSession.shared.data(for: request)
        
        guard let status = (res as? HTTPURLResponse)?.statusCode, status == 200 else {
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
        
        let (data, res) = try await URLSession.shared.data(for: request)
        
        guard let status = (res as? HTTPURLResponse)?.statusCode, status == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try BigAssDecoder.decode(BillingLoginResponse.self, from: data)
    }
}
