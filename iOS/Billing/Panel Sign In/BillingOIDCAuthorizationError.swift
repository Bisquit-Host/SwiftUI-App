import Foundation

nonisolated enum BillingOIDCAuthorizationError: LocalizedError {
    case invalidURL, invalidResponse, invalidRedirectURL
    case requestFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The authorization request URL is invalid"
        case .invalidResponse:
            "The authorization server returned an invalid response"
        case .invalidRedirectURL:
            "The authorization server returned an unsafe redirect"
        case .requestFailed(let statusCode):
            "The authorization request failed with status code \(statusCode)"
        }
    }
}
