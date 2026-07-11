import Foundation

nonisolated struct BillingOIDCAuthorizationDecision: Decodable, Sendable {
    let redirectURL: String

    private enum CodingKeys: String, CodingKey {
        case redirectURL = "redirectUrl"
    }
}
