import Foundation

struct BillingOperationsResponse: Decodable, Equatable {
    let operations: [BillingOperation]
    let total: Int
}

struct BillingOperation: Identifiable, Decodable, Equatable {
    let id: Int
    let amount: Double
    let type: BillingOperationType
    let date: Date
    let currency: BillingTransactionCurrency
    let messages: [BillingOperationMessage]
    
    var primaryMessage: String? {
        messages.first(where: { $0.lang.lowercased() == "en" })?.text ?? messages.first?.text
    }
    
    static let preview = BillingOperation(
        id: 1,
        amount: 16,
        type: .plus,
        date: Date(),
        currency: .eur,
        messages: []
    )
}

struct BillingOperationMessage: Decodable, Equatable {
    let lang: String
    let text: String
}

enum BillingOperationType: String, Decodable, Equatable {
    case plus, minus
}
