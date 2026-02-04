import SwiftUI
import BisquitoNet

struct PaymentProvider: Identifiable, Equatable, CaseIterable {
    let id: String
    let name: String
    let icon: PaymentProviderIcon
    let method: String?
    let currency: BillingCurrency
    
    private static let tBank = PaymentProvider(id: "card", name: "T-Bank", icon: .asset(.tbank), method: "card", currency: .RUB)
    private static let stripe = PaymentProvider(id: "stripe", name: "Stripe", icon: .asset(.stripe), method: "stripe", currency: .EUR)
    
    static let allCases: [PaymentProvider] = [
        tBank, stripe
    ]
    
    static func providers(for currency: BillingCurrency) -> [PaymentProvider] {
        switch currency {
        case .RUB: [tBank]
        default: [stripe]
        }
    }
    
}

enum PaymentProviderIcon: Equatable {
    case asset(ImageResource), system(String)
}
