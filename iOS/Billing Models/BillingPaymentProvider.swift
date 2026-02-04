import Foundation

struct PaymentGatewayInfo: Decodable, Equatable {
    let id: String
    let name: String
    let chargeCurrencies: [String]
    let defaultChargeCurrency: String
    let resolvedChargeCurrency: String?
}

struct PaymentGatewaysResponse: Decodable, Equatable {
    let gateways: [PaymentGatewayInfo]
}
