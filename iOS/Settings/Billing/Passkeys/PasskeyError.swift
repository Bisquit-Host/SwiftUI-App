import Foundation

enum PasskeyError: LocalizedError {
    case invalidChallenge, invalidUserId, invalidCredential, missingRelyingParty
    
    var errorDescription: String? {
        switch self {
        case .invalidChallenge:    "Unable to decode the passkey challenge"
        case .invalidUserId:       "Unable to decode the user identifier"
        case .invalidCredential:   "Passkey response is invalid"
        case .missingRelyingParty: "Relying party identifier is missing"
        }
    }
}
