struct BillingAuthService: Decodable, Identifiable, Sendable {
    let name: BillingAuthServiceName
    let available: Bool
    
    var id: BillingAuthServiceName {
        name
    }
}
