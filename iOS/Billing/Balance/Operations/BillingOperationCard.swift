import ScrechKit
import BisquitoNet

struct BillingOperationCard: View {
    private let operation: BillingOperation
    
    init(_ operation: BillingOperation) {
        self.operation = operation
    }
    
    private var positiveOperation: Bool {
        operation.type == .plus
    }
    
    private var amountColor: Color {
        positiveOperation ? .green : .red
    }
    
    private var amountText: String {
        let type = positiveOperation ? "+" : "−"
        let value = formatCurrencyValue(
            Int64(abs(operation.amount)),
            currency: operation.currency,
            minimumFractionDigits: 0,
            maximumFractionDigits: operation.currency.fractionDigits
        )
        return "\(type)\(value) \(operation.currency.displaySymbol)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 5) {
                BillingOperationCardIcon(positiveOperation)
                
                Text(operation.primaryMessage ?? String(localized: "Operation"))
                    .subheadline(.semibold)
                    .lineLimit(2)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(amountText)
                        .monospacedDigit()
                        .subheadline(.semibold)
                        .foregroundStyle(amountColor)
                    
                    Text(timeSinceISO(operation.date))
                        .caption()
                        .secondary()
                }
            }
        }
        //        .padding(.vertical, 6)
    }
}

#Preview {
    BillingOperationCard(.preview)
        .darkSchemePreferred()
        .scenePadding()
}
