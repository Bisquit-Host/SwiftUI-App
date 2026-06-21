#if os(iOS)
import AppIntents
import Foundation
import Calagopus

struct GetBillingOperationHistoryIntent: AppIntent {
    static let title: LocalizedStringResource = "Billing Operation History"
    static let description = IntentDescription("Fetches your recent billing operation history")
    
    @Parameter(title: "Operation Count", default: 5)
    var operationCount: Int
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get the last \(\.$operationCount) billing operations")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard let accessToken = billingAccessToken() else {
            throw BillingOperationHistoryIntentError.notSignedIn
        }
        
        let count = min(max(operationCount, 1), 10)
        let operations = try await fetchBillingOperations(accessToken: accessToken, count: count)
        
        guard !operations.isEmpty else {
            return .result(value: "No billing operations found", dialog: "No billing operations found")
        }
        
        let history = operations.map(operationSummary).joined(separator: "\n")
        let dialog = operations.count == 1 ? "Here is your latest billing operation" : "Here are your latest billing operations"
        
        return .result(value: history, dialog: "\(dialog):\n\(history)")
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
    
    private func fetchBillingOperations(accessToken: String, count: Int) async throws -> [BillingIntentOperation] {
        guard let url = URL(string: "https://api.bisquit.host/finances/operations?take=\(count)") else {
            throw BillingOperationHistoryIntentError.operationsUnavailable
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 204 {
                    return []
                }
                
                if response.statusCode == 401 {
                    throw BillingOperationHistoryIntentError.notSignedIn
                }
                
                guard response.statusCode < 400 else {
                    throw BillingOperationHistoryIntentError.operationsUnavailable
                }
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(BillingIntentOperationsResponse.self, from: data).operations
        } catch let error as BillingOperationHistoryIntentError {
            throw error
        } catch {
            throw BillingOperationHistoryIntentError.operationsUnavailable
        }
    }
    
    private func operationSummary(_ operation: BillingIntentOperation) -> String {
        let amount = formattedAmount(operation.amount, type: operation.type, currency: operation.currency)
        let message = operation.primaryMessage ?? "Operation"
        let date = operation.date.formatted(date: .abbreviated, time: .shortened)
        
        return "\(date): \(message), \(amount)"
    }
    
    private func formattedAmount(_ amount: Int64, type: BillingIntentOperationType, currency: BillingOperationIntentCurrency) -> String {
        let prefix = type == .plus ? "+" : "-"
        let value = formattedCurrencyValue(abs(amount), currency: currency)
        
        return prefix + currency.symbol + " " + value
    }
    
    private func formattedCurrencyValue(_ amount: Int64, currency: BillingOperationIntentCurrency) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = currency.fractionDigits
        
        let numerator = NSDecimalNumber(value: amount)
        let denominator = NSDecimalNumber(value: currency.scale)
        let value = numerator.dividing(by: denominator)
        
        return formatter.string(from: value) ?? value.stringValue
    }
}

private enum BillingOperationHistoryIntentError: LocalizedError {
    case notSignedIn, operationsUnavailable
    
    var errorDescription: String? {
        switch self {
        case .notSignedIn: "Sign in to billing before fetching your operation history"
        case .operationsUnavailable: "Unable to fetch your billing operation history"
        }
    }
}

nonisolated private struct BillingIntentOperationsResponse: Decodable {
    let operations: [BillingIntentOperation]
}

nonisolated private struct BillingIntentOperation: Decodable {
    let amount: Int64
    let type: BillingIntentOperationType
    let date: Date
    let currency: BillingOperationIntentCurrency
    let messages: [BillingIntentOperationMessage]
    
    var primaryMessage: String? {
        messages.first(where: { $0.lang.lowercased() == "en" })?.text ?? messages.first?.text
    }
}

nonisolated private struct BillingIntentOperationMessage: Decodable {
    let lang: String
    let text: String
}

nonisolated private enum BillingIntentOperationType: String, Decodable {
    case plus, minus
}

nonisolated private enum BillingOperationIntentCurrency: String, Decodable {
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
