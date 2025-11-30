import SwiftUI

struct BillingOperationRow: View {
    private let operation: BillingOperation
    
    init(_ operation: BillingOperation) {
        self.operation = operation
    }
    
    private var amountColor: Color {
        operation.type.lowercased() == "plus" ? .green : .red
    }
    
    private var amountText: String {
        let sign = operation.type.lowercased() == "plus" ? "+" : "−"
        return "\(sign)\(operation.amount) \(operation.currency.uppercased())"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: operation.type.lowercased() == "plus" ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .largeTitle()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(amountColor, .primary.opacity(0.25))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(operation.primaryMessage ?? "Operation")
                        .headline()
                        .lineLimit(2)
                    
                    Text(iso8601RelativeDate(operation.date))
                        .caption()
                        .secondary()
                }
                
                Spacer()
                
                Text(amountText)
                    .monospacedDigit()
                    .subheadline(.semibold)
                    .foregroundStyle(amountColor)
            }
        }
        .padding(.vertical, 6)
    }
}
