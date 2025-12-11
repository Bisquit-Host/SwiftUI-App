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
        case .EUR: 5
        case .RUB: 50
        }
    }
}

#warning("Remove after api update")
public enum BillingTransactionCurrency: String, Decodable, CaseIterable {
    case eur, rub
    
    var symbol: String {
        switch self {
        case .eur: "€"
        case .rub: "₽"
        }
    }
    
    var stepAmount: Double {
        switch self {
        case .eur: 5
        case .rub: 50
        }
    }
}
