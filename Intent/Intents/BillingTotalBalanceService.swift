import Foundation
import BisquitoNet

@MainActor
enum BillingTotalBalanceService {
    static func loadFormattedBalance() async throws -> String {
        guard let accessToken = BillingIntentAccessToken.load() else {
            throw BillingBalanceIntentError.notSignedIn
        }
        
        guard let user: BillingUser = await fetchUserInfoAPI(accessToken: accessToken) else {
            throw BillingBalanceIntentError.balanceUnavailable
        }
        
        return formattedBalance(user.totalBalance, currency: user.currency)
    }
    
    private static func formattedBalance(_ amount: Int64, currency: BillingCurrency) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = currency.fractionDigits
        
        let numerator = NSDecimalNumber(value: amount)
        let denominator = NSDecimalNumber(value: currency.scale)
        let value = numerator.dividing(by: denominator)
        let formattedValue = formatter.string(from: value) ?? value.stringValue
        
        return currency.symbol + " " + formattedValue
    }
}

enum BillingBalanceIntentError: LocalizedError {
    case notSignedIn, balanceUnavailable
    
    var errorDescription: String? {
        switch self {
        case .notSignedIn: "Sign in to billing before fetching your balance"
        case .balanceUnavailable: "Unable to fetch your billing balance"
        }
    }
}
