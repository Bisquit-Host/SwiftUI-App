import Foundation

enum TopupAlertContext {
    case serviceBilling, upgrade, purchase
}

func isInsufficientFundsError(_ title: String, subtitle: String) -> Bool {
    let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if normalizedTitle.caseInsensitiveCompare("Insufficient funds") == .orderedSame {
        return true
    }
    
    let combined = (normalizedTitle + " " + subtitle).lowercased()
    
    return combined.contains("insufficient funds")
        || combined.contains("insufficient balance")
        || combined.contains("not enough balance")
}
