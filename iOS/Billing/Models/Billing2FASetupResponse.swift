struct Billing2FASetupResponse: Decodable, Equatable {
    let url: String
    let accountName: String
    let secret: String
}
