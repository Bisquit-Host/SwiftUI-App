struct BillingOperationsResponse: Decodable, Equatable {
    let operations: [BillingOperation]
    let total: Int
}

struct BillingOperation: Identifiable, Decodable, Equatable {
    let id: Int
    let amount: Double
    let type: String
    let date: String
    let currency: String
    let messages: [BillingOperationMessage]
    
    var primaryMessage: String? {
        messages.first(where: { $0.lang.lowercased() == "en" })?.text ?? messages.first?.text
    }
}

struct BillingOperationMessage: Decodable, Equatable {
    let lang: String
    let text: String
}
