import SwiftUI

struct BillingDashboardBalance: View {
    private let user: BillingUser
    private let balance: Double
    private let currency: BillingCurrency
    
    init(_ user: BillingUser) {
        self.user = user
        self.balance = user.totalBalance
        self.currency = user.currency
    }
    
    @State private var sheetTopup = false
    
    var body: some View {
        let formattedBalance = String(format: "%.2f", balance)
        let isPositive = balance.isNormal && balance >= 0
        let iconColor: Color = isPositive ? .yellow : .red
        
        Button {
            sheetTopup = true
        } label: {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundStyle(iconColor.gradient)
                
                if isPositive {
                    Text(formattedBalance + currency.symbol)
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
