import Foundation

nonisolated struct BillingOIDCPendingAuthorization: Decodable, Sendable {
    let requestID: String
    let clientID: String
    let clientName: String
    let redirectURI: String
    let scopes: [String]
    let expiresAt: String

    private enum CodingKeys: String, CodingKey {
        case requestID = "requestId"
        case clientID = "clientId"
        case clientName
        case redirectURI = "redirectUri"
        case scopes, expiresAt
    }
}
