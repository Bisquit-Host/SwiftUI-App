import Foundation
import BisquitoNet

extension BillingLanguage {
    var localizedName: String {
        Locale.current.localizedString(forIdentifier: rawValue.lowercased()) ?? rawValue
    }
}
