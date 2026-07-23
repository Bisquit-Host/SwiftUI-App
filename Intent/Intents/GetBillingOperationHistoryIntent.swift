#if os(iOS)
import Foundation
import AppIntents
import BisquitoNet

struct GetBillingOperationHistoryIntent: AppIntent {
    static let title: LocalizedStringResource = "Billing Operation History"
    static let description = IntentDescription("Fetches your recent billing operation history")
    
    @Parameter(title: "Operation Count", default: 5)
    var operationCount: Int
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get the last \(\.$operationCount) billing operations")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard let accessToken = BillingIntentAccessToken.load() else {
            throw BillingOperationHistoryIntentError.notSignedIn
        }
        
        let count = min(max(operationCount, 1), 10)

        guard let operations = await fetchOperationsAPI(accessToken: accessToken, take: count) else {
            throw BillingOperationHistoryIntentError.operationsUnavailable
        }
        
        guard !operations.isEmpty else {
            return .result(value: "No billing operations found", dialog: "No billing operations found")
        }
        
        let history = operations.map(operationSummary).joined(separator: "\n")
        let dialog = operations.count == 1 ? "Here is your latest billing operation" : "Here are your latest billing operations"
        
        return .result(value: history, dialog: "\(dialog):\n\(history)")
    }
    
    private func operationSummary(_ operation: BillingOperation) -> String {
        let amount = formattedAmount(operation.amount, type: operation.type, currency: operation.currency)
        let message = operation.primaryMessage ?? "Operation"
        let date = operation.date.formatted(date: .abbreviated, time: .shortened)
        
        return "\(date): \(message), \(amount)"
    }
    
    private func formattedAmount(_ amount: Int64, type: BillingOperationType, currency: BillingCurrency) -> String {
        let prefix = type == .plus ? "+" : "-"
        let value = formattedCurrencyValue(abs(amount), currency: currency)
        
        return prefix + currency.symbol + " " + value
    }
    
    private func formattedCurrencyValue(_ amount: Int64, currency: BillingCurrency) -> String {
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
#endif
