import SwiftUI
import BisquitoNet

struct BillingDashboardBalance: View {
#if DEBUG
    @EnvironmentObject private var store: ValueStore
#endif
    private let balance: Int64
    private let currency: BillingCurrency
    private let topupAction: () -> Void
    
    init(_ user: BillingUser, topupAction: @escaping () -> Void) {
        self.balance = user.totalBalance
        self.currency = user.currency
        self.topupAction = topupAction
    }
    
    var body: some View {
#if DEBUG
        let balance = store.overrideBillingBalance ? 6_416 : self.balance
        let currency: BillingCurrency = store.overrideBillingBalance ? .EUR : self.currency
#endif
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
        .secondary()
        .semibold()
        .monospacedDigit()
    }
}

#Preview {
    BillingDashboardBalance(.preview) {}
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
