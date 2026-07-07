enum BillingAuthServiceName: String, Decodable, Sendable, CaseIterable {
    case apple, github, google, yandex, unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = BillingAuthServiceName(rawValue: rawValue) ?? .unknown
    }
}
