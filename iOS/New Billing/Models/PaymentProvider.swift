import SwiftUI

struct PaymentProvider: Identifiable, Equatable, CaseIterable {
    let id: String
    let name: String
    let icon: PaymentProviderIcon
    let tint: Color
    let method: String?
    
    private static let tBank = PaymentProvider(id: "card", name: "T-Bank", icon: .asset(.tbank), tint: .yellow, method: "card")
    private static let stripe = PaymentProvider(id: "stripe", name: "Stripe", icon: .asset(.stripe), tint: .indigo, method: "stripe")
    
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
    case asset(ImageResource),
         system(String)
}
