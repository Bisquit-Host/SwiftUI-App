struct BillingTwoFASetupResponse: Decodable, Equatable {
    let url: String
    let accountName: String
    let secret: String
}
