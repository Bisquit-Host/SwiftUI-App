import ScrechKit

struct BillingOperationRow: View {
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
        return "\(type)\(operation.amount) \(operation.currency.symbol)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: positiveOperation ? "arrow.down" : "arrow.up")
                    .fontSize(18)
                    .semibold()
                    .padding(6)
                    .glassEffect(.regular.tint(positiveOperation ? Color.green.opacity(0.5) : Color.red.opacity(0.5)), in: .circle)
                    .foregroundStyle(positiveOperation ? Color.green.gradient : Color.red.gradient)
                    .padding(5)
                
                Text(operation.primaryMessage ?? "Operation")
                    .headline()
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
        .padding(.vertical, 6)
    }
}

#Preview {
    BillingOperationRow(.preview)
        .darkSchemePreferred()
        .scenePadding()
}
