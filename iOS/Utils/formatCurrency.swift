import Foundation

func formatCurrency(_ amount: Double, user: BillingUser?) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2
    
    let value = formatter.string(from: NSNumber(value: amount)) ?? amount.formatted(.fractionDigits(2))
    
    if let user {
        return user.currency.symbol + " " + value
    } else {
        return value
    }
}
