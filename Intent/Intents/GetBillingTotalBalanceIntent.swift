#if os(iOS)
import AppIntents
import Foundation
import PteroNet

struct GetBillingTotalBalanceIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Total Balance"
    static let description = IntentDescription("Fetches your total billing balance")
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get total balance")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard let accessToken = billingAccessToken() else {
            throw BillingBalanceIntentError.notSignedIn
        }
        
        let user = try await fetchBillingUser(accessToken: accessToken)
        
        let balance = formattedBalance(user.totalBalance, currency: user.currency)
        return .result(value: balance, dialog: "Your total balance is \(balance)")
    }
    
    private func billingAccessToken() -> String? {
        if let sessionToken = Keychain.load(key: "session_token"), !sessionToken.isEmpty {
            return sessionToken
        }
        
        if let legacyAccessToken = Keychain.load(key: "access_token"), !legacyAccessToken.isEmpty {
            return legacyAccessToken
        }
        
        return nil
    }
    
    private func fetchBillingUser(accessToken: String) async throws -> BillingIntentUser {
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
    
    private func formattedBalance(_ amount: Int64, currency: BillingIntentCurrency) -> String {
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

private enum BillingBalanceIntentError: LocalizedError {
    case notSignedIn, balanceUnavailable
    
    var errorDescription: String? {
        switch self {
        case .notSignedIn: "Sign in to billing before fetching your balance"
        case .balanceUnavailable: "Unable to fetch your billing balance"
        }
    }
}

nonisolated private struct BillingIntentUser: Decodable {
    let currency: BillingIntentCurrency
    let totalBalance: Int64
}

nonisolated private enum BillingIntentCurrency: String, Decodable {
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
