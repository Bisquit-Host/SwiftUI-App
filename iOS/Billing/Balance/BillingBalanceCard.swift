import SwiftUI

struct BillingBalanceCard: View {
    private let title: LocalizedStringKey
    private let value: String
    private let isTotal: Bool
    
    init(_ title: LocalizedStringKey, value: String) {
        self.title = title
        self.value = value
        isTotal = title == "Total balance"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .fontWeight(isTotal ? .semibold : .regular)
            
            Spacer()
            
            Text(value)
                .rounded()
                .numericTransition()
                .foregroundStyle(isTotal ? .primary : .secondary)
                .fontWeight(isTotal ? .semibold : .regular)
                .font(isTotal ? .body : .subheadline)
        }
    }
}
