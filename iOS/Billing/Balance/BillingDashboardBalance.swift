import SwiftUI
import BisquitoNet

struct BillingDashboardBalance: View {
    private let user: BillingUser
    private let balance: Int64
    private let currency: BillingCurrency
    
    init(_ user: BillingUser) {
        self.user = user
        self.balance = user.totalBalance
        self.currency = user.currency
    }
    
    @State private var sheetTopup = false
    
    var body: some View {
        let formattedBalance = formatCurrencyValue(
            balance,
            currency: currency,
            minimumFractionDigits: currency.fractionDigits,
            maximumFractionDigits: currency.fractionDigits
        )
        let isPositive = balance >= 0
        let iconColor: Color = isPositive ? .yellow : .red
        
        Button {
            sheetTopup = true
        } label: {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundStyle(iconColor.gradient)
                
                if isPositive {
                    Text(formattedBalance + " " + currency.displaySymbol)
                } else {
                    Text("Top up")
                }
            }
        }
        .rounded()
        .semibold()
        .monospacedDigit()
        .sheet($sheetTopup) {
            NavigationStack {
                SheetTopup(user)
            }
        }
    }
}

#Preview {
    BillingDashboardBalance(.preview)
        .darkSchemePreferred()
}
