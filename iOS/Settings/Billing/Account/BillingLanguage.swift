import Foundation

enum BillingLanguage: String, CaseIterable, Identifiable, Sendable {
    case RU, EN
    
    var id: String {
        rawValue
    }
    
    var localizedName: String {
        Locale.current.localizedString(forIdentifier: rawValue.lowercased()) ?? rawValue
    }
}
