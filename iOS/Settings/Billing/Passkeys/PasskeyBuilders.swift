import Foundation
import AuthenticationServices
import BisquitoNet

struct PasskeyRequestFactory {
    static func assertionRequest(from options: PasskeyAssertionOptions) throws -> ASAuthorizationPlatformPublicKeyCredentialAssertionRequest {
        guard let challenge = options.challenge.dataFromBase64URL() else {
            throw PasskeyError.invalidChallenge
        }
        
        guard let rpId = options.rpId, !rpId.isEmpty else {
            throw PasskeyError.missingRelyingParty
        }
        
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let req = provider.createCredentialAssertionRequest(challenge: challenge)
        
        if let allowCredentials = options.allowCredentials {
            req.allowedCredentials = allowCredentials.compactMap { descriptor in
                guard let id = descriptor.id.dataFromBase64URL() else { return nil }
                return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: id)
            }
        }
        
        if let userVerification = options.userVerification?.userVerificationPreference {
            req.userVerificationPreference = userVerification
        }
        
        return req
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
    static func assertionPayload(_ credential: ASAuthorizationPlatformPublicKeyCredentialAssertion) throws -> PasskeyAssertionPayload {
        let credentialId = credential.credentialID.base64URLEncodedString()
        
        let response = PasskeyAssertionResponsePayload(
            clientDataJSON: credential.rawClientDataJSON.base64URLEncodedString(),
            authenticatorData: credential.rawAuthenticatorData.base64URLEncodedString(),
            signature: credential.signature.base64URLEncodedString(),
            userHandle: credential.userID?.base64URLEncodedString()
        )
        
        return PasskeyAssertionPayload(id: credentialId, rawId: credentialId, response: response)
    }
    
    static func attestationPayload(_ credential: ASAuthorizationPlatformPublicKeyCredentialRegistration) throws -> PasskeyAttestationPayload {
        let credentialId = credential.credentialID.base64URLEncodedString()
        
        guard let attestationObject = credential.rawAttestationObject?.base64URLEncodedString() else {
            throw PasskeyError.invalidCredential
        }
        
        let response = PasskeyAttestationResponsePayload(
            clientDataJSON: credential.rawClientDataJSON.base64URLEncodedString(),
            attestationObject: attestationObject,
            transports: ["internal"]
        )
        
        return PasskeyAttestationPayload(id: credentialId, rawId: credentialId, response: response)
    }
}

fileprivate extension String {
    var userVerificationPreference: ASAuthorizationPublicKeyCredentialUserVerificationPreference? {
        switch lowercased() {
        case "required":    .required
        case "discouraged": .discouraged
        case "preferred":   fallthrough
        default:            .preferred
        }
    }
}
