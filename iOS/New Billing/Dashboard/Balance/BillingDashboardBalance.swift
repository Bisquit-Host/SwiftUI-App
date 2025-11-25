import SwiftUI

struct BillingDashboardBalance: View {
    let balance: Double
    let currency: String
    
    private var currencySymbol: String {
        switch currency {
        case "EUR": "€"
        case "RUB": "₽"
        default: ""
        }
    }
    
    @State private var sheetTopup = false
    
    var body: some View {
        let formattedBalance = String(format: "%.2f", balance)
        let isPositive = balance.isNormal && balance >= 0
        let iconColor: Color = isPositive ? .yellow : .red
        
        Button {
            
        } label: {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundStyle(iconColor.gradient)
                
                if isPositive {
                    Text(formattedBalance + currencySymbol)
                } else {
                    Text("Top up")
                }
            }
        }
        .rounded()
        .semibold()
        .monospacedDigit()
        .sheet($sheetTopup) {
            SheetTopup()
        }
    }
}

#Preview {
    BillingDashboardBalance(balance: 200, currency: "EUR")
        .darkSchemePreferred()
}
