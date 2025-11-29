import SwiftUI

struct BillingOperationRow: View {
    let operation: BillingOperation
    
    init(_ operation: BillingOperation) {
        self.operation = operation
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(operation.primaryMessage ?? "Operation")
                .headline()
            
            Text(operation.date)
                .caption()
                .secondary()
            
            HStack {
                Text(operation.type.capitalized)
                
                Spacer()
                
                Text("\(operation.amount, specifier: "%.2f") \(operation.currency.uppercased())")
                    .monospacedDigit()
            }
            .subheadline()
        }
        .padding(.vertical, 4)
    }
}
