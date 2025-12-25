enum BillingAuthProvider: String {
    case github, google, yandex
}

struct AuthURLResponse: Decodable {
    let url: String
}
