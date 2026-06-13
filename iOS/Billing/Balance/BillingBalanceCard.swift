import ScrechKit

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
            
            if isTotal {
                Text(value)
                    .rounded()
                    .numericTransition()
                    .semibold()
            } else {
                Text(value)
                    .rounded()
                    .numericTransition()
                    .secondary()
                    .subheadline()
            }
        }
    }
}
