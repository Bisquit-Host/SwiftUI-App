import SwiftUI

struct BillingOperationCardIcon: View {
    private let positiveOperation: Bool
    
    init(_ positiveOperation: Bool) {
        self.positiveOperation = positiveOperation
    }
    
    var body: some View {
        Image(systemName: positiveOperation ? "arrow.down" : "arrow.up")
            .fontSize(18)
            .semibold()
            .padding(6)
            .glassEffect(.regular.tint(positiveOperation ? Color.green.opacity(0.5) : Color.red.opacity(0.5)), in: .circle)
            .foregroundStyle(positiveOperation ? Color.green.gradient : Color.red.gradient)
            .padding(5)
    }
}

#Preview {
    HStack {
        BillingOperationCardIcon(true)
        BillingOperationCardIcon(false)
    }
    .darkSchemePreferred()
}
