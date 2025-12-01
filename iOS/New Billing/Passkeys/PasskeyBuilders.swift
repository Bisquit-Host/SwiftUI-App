import AuthenticationServices
import Foundation

enum PasskeyError: LocalizedError {
    case invalidChallenge, invalidUserId, invalidCredential, missingRelyingParty
    
    var errorDescription: String? {
        switch self {
        case .invalidChallenge:    "Unable to decode the passkey challenge."
        case .invalidUserId:       "Unable to decode the user identifier."
        case .invalidCredential:   "Passkey response is invalid."
        case .missingRelyingParty: "Relying party identifier is missing."
        }
    }
}

struct PasskeyRequestFactory {
    static func assertionRequest(from options: PasskeyAssertionOptions) throws -> ASAuthorizationPlatformPublicKeyCredentialAssertionRequest {
        guard let challenge = options.challenge.dataFromBase64URL() else {
            throw PasskeyError.invalidChallenge
        }
        
        guard let rpId = options.rpId, !rpId.isEmpty else {
            throw PasskeyError.missingRelyingParty
        }
        
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let request = provider.createCredentialAssertionRequest(challenge: challenge)
        
        if let allowCredentials = options.allowCredentials {
            request.allowedCredentials = allowCredentials.compactMap { descriptor in
                guard let id = descriptor.id.dataFromBase64URL() else { return nil }
                return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: id)
            }
        }
        
        if let userVerification = options.userVerification?.userVerificationPreference {
            request.userVerificationPreference = userVerification
        }
        
        return request
    }
    
    static func registrationRequest(from options: PasskeyRegistrationOptions) throws -> ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest {
        guard let challenge = options.challenge.dataFromBase64URL() else {
            throw PasskeyError.invalidChallenge
        }
        
        guard let userId = options.user.id.dataFromBase64URL() else {
            throw PasskeyError.invalidUserId
        }
        
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: options.rp.id)
        let request = provider.createCredentialRegistrationRequest(challenge: challenge, name: options.user.name, userID: userId)
        
        if let userVerification = options.authenticatorSelection?.userVerification?.userVerificationPreference {
            request.userVerificationPreference = userVerification
        }
        
        return request
    }
}

struct PasskeyCredentialFormatter {
    static func assertionPayload(_ credential: ASAuthorizationPlatformPublicKeyCredentialAssertion) throws -> [String: Any] {
        let credentialId = credential.credentialID.base64URLEncodedString()
        
        var response: [String: Any] = [
            "clientDataJSON":    credential.rawClientDataJSON.base64URLEncodedString(),
            "authenticatorData": credential.rawAuthenticatorData.base64URLEncodedString(),
            "signature":         credential.signature.base64URLEncodedString()
        ]
        
        if let userHandle = credential.userID?.base64URLEncodedString() {
            response["userHandle"] = userHandle
        }
        
        return [
            "id":       credentialId,
            "rawId":    credentialId,
            "type":     "public-key",
            "response": response
        ]
    }
    
    static func attestationPayload(_ credential: ASAuthorizationPlatformPublicKeyCredentialRegistration) throws -> [String: Any] {
        let credentialId = credential.credentialID.base64URLEncodedString()
        
        guard let attestationObject = credential.rawAttestationObject?.base64URLEncodedString() else {
            return [:]
        }
        
        var response: [String: Any] = [
            "clientDataJSON": credential.rawClientDataJSON.base64URLEncodedString(),
            "attestationObject": attestationObject
        ]
        
        response["transports"] = ["internal"]
        
        return [
            "id": credentialId,
            "rawId": credentialId,
            "type": "public-key",
            "response": response
        ]
    }
}

private extension String {
    var userVerificationPreference: ASAuthorizationPublicKeyCredentialUserVerificationPreference? {
        switch lowercased() {
        case "required":    .required
        case "discouraged": .discouraged
        case "preferred":   fallthrough
        default:            .preferred
        }
    }
}
