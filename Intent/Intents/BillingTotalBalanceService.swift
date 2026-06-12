#if os(iOS)
import Foundation
import PteroNet

enum BillingTotalBalanceService {
    static func loadFormattedBalance() async throws -> String {
        guard let accessToken = BillingIntentAccessToken.load() else {
            throw BillingBalanceIntentError.notSignedIn
        }
        
        let user = try await fetchBillingUser(accessToken: accessToken)
        return formattedBalance(user.totalBalance, currency: user.currency)
    }
    
    private static func fetchBillingUser(accessToken: String) async throws -> BillingIntentUser {
        guard let url = URL(string: "https://api.bisquit.host/user") else {
            throw BillingBalanceIntentError.balanceUnavailable
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 401 {
                    throw BillingBalanceIntentError.notSignedIn
                }
                
                guard response.statusCode < 400 else {
                    throw BillingBalanceIntentError.balanceUnavailable
                }
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(BillingIntentUser.self, from: data)
        } catch let error as BillingBalanceIntentError {
            throw error
        } catch {
            throw BillingBalanceIntentError.balanceUnavailable
        }
    }
    
    private static func formattedBalance(_ amount: Int64, currency: BillingIntentCurrency) -> String {
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

nonisolated struct BillingIntentUser: Decodable {
    let currency: BillingIntentCurrency
    let totalBalance: Int64
}

nonisolated enum BillingIntentCurrency: String, Decodable {
    case EUR, RUB
    
    nonisolated var symbol: String {
        switch self {
        case .EUR: "€"
        case .RUB: "₽"
        }
    }
    
    nonisolated var fractionDigits: Int {
        switch self {
        case .EUR, .RUB: 2
        }
    }
    
    nonisolated var scale: Int64 {
        var result: Int64 = 1
        
        for _ in 0..<fractionDigits {
            result *= 10
        }
        
        return result
    }
}
#endif
