import Foundation

nonisolated struct AttestAssertionClientData: Encodable {
    let challenge: String
    let action: String
    let payloadHash: String
}
