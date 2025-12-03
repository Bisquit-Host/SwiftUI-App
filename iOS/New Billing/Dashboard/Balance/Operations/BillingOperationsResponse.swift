struct BillingOperationsResponse: Decodable, Equatable {
    let operations: [BillingOperation]
    let total: Int
}

struct BillingOperation: Identifiable, Decodable, Equatable {
    let id: Int
    let amount: Double
    let type: BillingOperationType
    let date: String
    let currency: BillingCurrency
    let messages: [BillingOperationMessage]
    
    var primaryMessage: String? {
        messages.first(where: { $0.lang.lowercased() == "en" })?.text ?? messages.first?.text
    }
    
    static let preview = BillingOperation(
        id: 1,
        amount: 16,
        type: .plus,
        date: "2025-11-29T17:02:32.935387Z",
        currency: .EUR,
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
