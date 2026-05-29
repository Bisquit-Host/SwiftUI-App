import Foundation

enum AppleSignInError: LocalizedError {
    case invalidCredential, missingAuthorizationCode
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential: "Apple did not return a valid credential"
        case .missingAuthorizationCode: "Apple did not return an authorization code"
        }
    }
}
