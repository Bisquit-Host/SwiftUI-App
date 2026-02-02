nonisolated struct AttestRequest: Encodable {
    let challenge: String
    let attestation: String
    let keyID: String
}
