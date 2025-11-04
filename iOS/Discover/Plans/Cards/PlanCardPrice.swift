import SwiftUI

struct PlanCardPrice: View {
    @EnvironmentObject private var store: ValueStore
    
    private let prices: [PlanPrice]
    
    init(_ prices: [PlanPrice]) {
        self.prices = prices
    }
    
    private var price: Double? {
        switch store.preferredCurrency {
        case "€":
            prices.first { $0.currency == "eur" }?.price
            
        default:
            prices.first { $0.currency == "rub" }?.price
        }
    }
    
    var body: some View {
        if let price {
            Text(customRound(price) + store.preferredCurrency)
                .subheadline(.bold)
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .foregroundStyle(.white)
                .background(.blue, in: .capsule)
        }
    }
}

//#Preview {
//    PlanCardPrice()
//        .darkSchemePreferred()
//        .environmentObject(ValueStore())
//}
