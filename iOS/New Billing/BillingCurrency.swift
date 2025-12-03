import Foundation

public enum BillingCurrency: String, Decodable, CaseIterable {
    case EUR, RUB
    
    var symbol: String {
        switch self {
        case .EUR: "€"
        case .RUB: "₽"
        }
    }
    
    var stepAmount: Double {
        switch self {
        case .EUR: 4
        case .RUB: 50
        }
    }
}
