import SwiftUI
import BisquitoNet

struct BillingDashboardBalance: View {
    private let balance: Int64
    private let currency: BillingCurrency
    private let topupAction: () -> Void
    
    init(_ user: BillingUser, topupAction: @escaping () -> Void) {
        self.balance = user.totalBalance
        self.currency = user.currency
        self.topupAction = topupAction
    }
    
    var body: some View {
        let formattedBalance = formatCurrencyValue(
            balance,
            currency: currency,
            minimumFractionDigits: currency.fractionDigits,
            maximumFractionDigits: currency.fractionDigits
        )
        
        let isPositive = balance >= 0
        
        Button(action: topupAction) {
            if isPositive {
                Text(formattedBalance + " " + currency.displaySymbol)
            } else {
                Text("Top up")
            }
        }
        .rounded()
        .semibold()
        .monospacedDigit()
    }
}

#Preview {
    BillingDashboardBalance(.preview) {}
        .darkSchemePreferred()
}
