import Foundation

enum AttestError: LocalizedError {
    case notSupported,
         invalidResponse,
         serverError(String),
         keyGenerationFailed(Error),
         attestationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notSupported:
            "App Attest is not supported on this device"
            
        case .serverError(let message):
            message
            
        case .invalidResponse:
            "Invalid server response"
            
        case .keyGenerationFailed(let error):
            "Key generation failed: \(error)"
            
        case .attestationFailed(let error):
            "Attestation failed: \(error)"
        }
    }
}
