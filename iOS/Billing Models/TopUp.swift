struct TopupResponse: Decodable {
    let url: String
}

struct TopupRequest: Encodable {
    let amount: Double
    let method: String?
}

struct GiftCodeRequest: Encodable {
    let code: String
}

struct GiftCodeResponse: Decodable {
    let bonusBalance: Double
}
