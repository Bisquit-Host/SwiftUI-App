import SwiftUI

struct PaymentProvider: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: PaymentProviderIcon
    let tint: Color
    let method: String?
    
    static func providers(for currency: BillingCurrency) -> [PaymentProvider] {
        switch currency {
        case .RUB:
            [
                PaymentProvider(id: "card", name: "T-Bank", icon: .asset(.tbank), tint: .yellow, method: "card")
            ]
            
        default:
            [
                PaymentProvider(id: "stripe", name: "Stripe", icon: .asset(.stripe), tint: .indigo, method: "stripe")
            ]
        }
    }
}

enum PaymentProviderIcon: Equatable {
    case asset(ImageResource),
         system(String)
}
