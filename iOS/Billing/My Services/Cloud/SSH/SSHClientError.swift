import Foundation

enum SSHClientError: Error, LocalizedError {
    case internalInvariantViolated(String)
    
    var errorDescription: String? {
        switch self {
        case .internalInvariantViolated(let message):
            "SSH internal error: \(message)"
        }
    }
}
