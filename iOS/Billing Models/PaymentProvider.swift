import SwiftUI
import BisquitoNet

struct PaymentProvider: Identifiable, Equatable {
    let id: String
    let name: String
    let currency: BillingCurrency
    
    var icon: PaymentProviderIcon {
        switch normalizedId {
        case "card", "tbank", "t-bank": .asset(.tbank)
        case "stripe": .asset(.stripe)
        case "app_store": .system("apple.logo")
        default: .system("creditcard")
        }
    }
    
    var iconTransitionID: String {
        switch normalizedId {
        case "card", "tbank", "t-bank": "asset-tbank"
        case "stripe": "asset-stripe"
        case "app_store": "system-apple-logo"
        default: "system-creditcard"
        }
    }
    
    var method: String? {
        switch normalizedId {
        case "card", "tbank", "t-bank": "card"
        case "stripe": "stripe"
        case "app_store": "app_store"
        default: nil
        }
    }

    var isAppStore: Bool {
        normalizedId == "app_store"
    }

    static func appStore(currency: BillingCurrency) -> PaymentProvider {
        PaymentProvider(id: "app_store", name: "App Store", currency: currency)
    }

    init?(_ gateway: PaymentGatewayInfo) {
        let resolvedCurrency = gateway.resolvedChargeCurrency ?? gateway.defaultChargeCurrency
        guard let currency = BillingCurrency(rawValue: resolvedCurrency) else {
            return nil
        }
        
        id = gateway.id
        name = PaymentProvider.fallbackName(for: gateway.id, name: gateway.name)
        self.currency = currency
    }

    private init(id: String, name: String, currency: BillingCurrency) {
        self.id = id
        self.name = name
        self.currency = currency
    }

    private var normalizedId: String {
        id.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    private static func fallbackName(for id: String, name: String?) -> String {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmed, !trimmed.isEmpty {
            return trimmed
        }
        
        switch id.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "card", "tbank", "t-bank":
            return "T-Bank"
        case "stripe":
            return "Stripe"
        default:
            return id
        }
    }
}

enum PaymentProviderIcon: Equatable {
    case asset(ImageResource), system(String)
}
