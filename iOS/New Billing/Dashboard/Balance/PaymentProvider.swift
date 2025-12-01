import SwiftUI

struct PaymentProvider: Identifiable, Equatable {
    enum Icon: Equatable {
        case asset(ImageResource)
        case system(String)
    }
    
    let id: String
    let name: String
    let icon: Icon
    let tint: Color
    let method: String?
    
    static func providers(for currency: String) -> [PaymentProvider] {
        switch currency.uppercased() {
        case "RUB":
            [
                PaymentProvider(id: "card", name: "T-Bank", icon: .asset(.tbank), tint: .yellow, method: "card")
            ]
            
        default:
            [
                PaymentProvider(id: "stripe", name: "Stripe", icon: .system("creditcard.fill"), tint: .indigo, method: "stripe")
            ]
        }
    }
}
