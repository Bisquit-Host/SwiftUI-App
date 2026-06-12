nonisolated struct AttestAssertionResult: Encodable {
    let challenge: String
    let assertion: String
    let keyID: String
    let clientData: String
}
