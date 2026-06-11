import Foundation
import BisquitoNet

func formatCurrency(_ amount: Int64, user: BillingUser?) -> String {
    guard let user else {
        return formatCurrencyValue(amount, scale: 100, minimumFractionDigits: 0, maximumFractionDigits: 2)
    }
    
    let value = formatCurrencyValue(
        amount,
        scale: user.currency.scale,
        minimumFractionDigits: 0,
        maximumFractionDigits: user.currency.fractionDigits
    )
    
    return user.currency.displaySymbol + " " + value
}

func formatCurrencyValue(_ amount: Int64, currency: BillingCurrency, minimumFractionDigits: Int, maximumFractionDigits: Int) -> String {
    formatCurrencyValue(
        amount,
        scale: currency.scale,
        minimumFractionDigits: minimumFractionDigits,
        maximumFractionDigits: maximumFractionDigits
    )
}

func formatCurrencyInput(_ amount: Int64, currency: BillingCurrency) -> String {
    formatCurrencyValue(
        amount,
        scale: currency.scale,
        minimumFractionDigits: currency.fractionDigits,
        maximumFractionDigits: currency.fractionDigits
    )
}

func parseCurrencyInput(_ input: String, currency: BillingCurrency) -> Int64? {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
    let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
    
    guard let decimal = Decimal(string: normalized) else { return nil }
    
    let scaled = decimal * Decimal(currency.scale)
    var rounded = Decimal()
    var value = scaled
    NSDecimalRound(&rounded, &value, 0, .plain)
    
    return NSDecimalNumber(decimal: rounded).int64Value
}

private func formatCurrencyValue(
    _ amount: Int64,
    scale: Int64,
    minimumFractionDigits: Int,
    maximumFractionDigits: Int
) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = minimumFractionDigits
    formatter.maximumFractionDigits = maximumFractionDigits
    
    let numerator = NSDecimalNumber(value: amount)
    let denominator = NSDecimalNumber(value: scale)
    let number = numerator.dividing(by: denominator)
    
    return formatter.string(from: number) ?? number.stringValue
}

extension BillingCurrency {
    nonisolated var displaySymbol: String {
        switch self {
        case .EUR: "\u{20AC}"
        case .RUB: "\u{20BD}"
        }
    }
    
    nonisolated var fractionDigits: Int {
        switch self {
        case .EUR, .RUB: 2
        }
    }
    
    nonisolated var scale: Int64 {
        var result: Int64 = 1
        
        for _ in 0..<fractionDigits {
            result *= 10
        }
        
        return result
    }
    
    nonisolated var stepAmountMinor: Int64 {
        switch self {
        case .EUR: 5 * scale
        case .RUB: 50 * scale
        }
    }
    
    nonisolated var minimumTopupAmount: Int64 {
        switch self {
        case .EUR: 1 * scale
        case .RUB: 50 * scale
        }
    }
    
    nonisolated var defaultTopupAmount: Int64 {
        switch self {
        case .EUR: 10 * scale
        case .RUB: 500 * scale
        }
    }
}
