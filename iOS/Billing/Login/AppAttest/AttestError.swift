import Foundation
import Security

enum AttestError: LocalizedError {
    case notSupported,
         invalidResponse,
         missingKey,
         serverError(String),
         keychainFailed(OSStatus),
         keyGenerationFailed(Error),
         attestationFailed(Error),
         assertionFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notSupported:
            "App Attest is not supported on this device"
            
        case .serverError(let message):
            message
            
        case .invalidResponse:
            "Invalid server response"
            
        case .missingKey:
            "App Attest key is missing"
            
        case .keychainFailed(let status):
            "Keychain failed with status \(status)"
            
        case .keyGenerationFailed(let error):
            "Key generation failed: \(error)"
            
        case .attestationFailed(let error):
            "Attestation failed: \(error)"
            
        case .assertionFailed(let error):
            "Assertion failed: \(error)"
        }
    }
}
