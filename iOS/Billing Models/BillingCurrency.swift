import Foundation

public enum BillingCurrency: String, Decodable, CaseIterable {
    case EUR, RUB
    
    var symbol: String {
        switch self {
        case .EUR: "€"
        case .RUB: "₽"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .EUR: "eurosign"
        case .RUB: "rublesign"
        @unknown default: "dollarsign"
        }
    }
    
    var stepAmount: Double {
        switch self {
        case .EUR: 5
        case .RUB: 50
        }
    }
}
