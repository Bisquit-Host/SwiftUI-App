struct BillingAuthServicesResponse: Decodable, Sendable {
    let providers: [BillingAuthService]
}
