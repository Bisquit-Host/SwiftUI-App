import Foundation
import BisquitoNet
import AuthenticationServices
@preconcurrency import DeviceCheck

@Observable
final class LoginVM {
    var isPasskeyLoading = false
    var isVerifying2FA = false
    var isAttesting = false
    var attestationResult: AttestationResult?
    var selectedCurrency: BillingCurrency = .RUB
    
    private let passkeyAuth = PasskeyAuthorizationController()
    
    var isAppAttestSupported: Bool {
        DCAppAttestService.shared.isSupported
    }
    
    func performAppAttest(userID: String? = nil) async -> Bool {
        isAttesting = true
        
        defer {
            Task {
                try await Task.sleep(for: .seconds(0.5))
                isAttesting = false
            }
        }
        
        do {
            let result = try await AppAttestService.shared.attestDevice(userID: userID)
            attestationResult = result
            
            return true
        } catch {
            SystemAlert.error(error)
            return false
        }
    }
    
    func login(_ login: String, _ password: String, captchaToken: String? = nil, attestResponse: AttestationResult? = nil) async -> BillingLoginResponse? {
        let attestationPayload = attestResponse.map {
            [
                "challenge": $0.challenge,
                "attestation": $0.attestation,
                "keyID": $0.keyID
            ]
        }
        
        return await loginAPI(
            login: login,
            password: password,
            captchaToken: captchaToken,
            attestResponse: attestationPayload,
            onBillingError: { @MainActor title, subtitle in
                SystemAlert.error(title, subtitle: subtitle)
            }
        )
    }
    
    func signup(name: String, email: String, password: String, captchaToken: String? = nil, attestResponse: AttestationResult? = nil) async -> BillingLoginResponse? {
        let attestationPayload = attestResponse.map {
            [
                "challenge": $0.challenge,
                "attestation": $0.attestation,
                "keyID": $0.keyID
            ]
        }
        
        return await signupAPI(
            name: name,
            email: email,
            password: password,
            currency: selectedCurrency,
            captchaToken: captchaToken,
            attestResponse: attestationPayload,
            onBillingError: { @MainActor title, subtitle in
                SystemAlert.error(title, subtitle: subtitle)
            }
        )
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
            let session = try await startPasskeyLoginAPI(login: login)
            let req = try PasskeyRequestFactory.assertionRequest(from: session.options)
            let credential = try await passkeyAuth.perform(req)
            
            guard let assertion = credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion else {
                throw PasskeyError.invalidCredential
            }
            
            let payload = try PasskeyCredentialFormatter.assertionPayload(assertion)
            
            return try await verifyPasskeyLoginAPI(sessionId: session.sessionId, credential: payload)
        } catch {
            SystemAlert.error(error)
            return nil
        }
    }
}
