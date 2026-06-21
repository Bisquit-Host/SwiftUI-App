import Foundation
import Calagopus
import BisquitoNet
import AuthenticationServices

@Observable
final class PasskeyListVM {
    var passkeys: [PasskeyListItem] = []
    var isLoading = false
    var isRegistering = false
    var label = ""
    
    private let authController = PasskeyAuthorizationController()
    
    func fetchPasskeys() async {
        guard let accessToken = accessToken() else { return }
        
        isLoading = true
        defer { isLoading = false }
        passkeys = await fetchPasskeysAPI(
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) ?? []
    }
    
    func deletePasskey(_ passkey: PasskeyListItem) async {
        guard let accessToken = accessToken() else { return }
        guard await deletePasskeyAPI(
            passkeyId: passkey.id,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) != nil else { return }
        
        passkeys.removeAll {
            $0.id == passkey.id
        }
    }
    
    func registerPasskey() async {
        isRegistering = true
        defer { isRegistering = false }
        guard let session = await startRegistration() else { return }
        
        do {
            let req = try PasskeyRequestFactory.registrationRequest(from: session.options)
            let credential = try await authController.perform(req)
            
            guard let registration = credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration else {
                throw PasskeyError.invalidCredential
            }
            
            let payload = try PasskeyCredentialFormatter.attestationPayload(registration)
            
            guard await verifyRegistration(sessionId: session.sessionId, credential: payload) else {
                return
            }
            
            label = ""
            
            await fetchPasskeys()
        } catch {
            SystemAlert.error(error)
            Logger().error("Passkey registration failed: \(error)")
        }
    }
    
    private func startRegistration() async -> PasskeyOptionsResponse<PasskeyRegistrationOptions>? {
        guard let accessToken = accessToken() else { return nil }
        
        return await startPasskeyRegistrationAPI(
            label: label,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        )
    }
    
    private func verifyRegistration(sessionId: String, credential: PasskeyAttestationPayload) async -> Bool {
        guard let accessToken = accessToken() else { return false }
        
        return await verifyPasskeyRegistrationAPI(
            sessionId: sessionId,
            credential: credential,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) != nil
    }
}
