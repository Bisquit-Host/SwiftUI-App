import SwiftUI

struct BillingBalanceRow: View {
    private let title: LocalizedStringKey
    private let icon: String
    private let tint: Color
    private let value: String
    private let isTotal: Bool
    
    init(_ title: LocalizedStringKey, icon: String, tint: Color, value: String) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.value = value
        isTotal = title == "Total"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .footnote()
                .frame(32)
                .glassEffect(.regular.tint(tint.opacity(0.15)), in: .rect(cornerRadius: 10))
                .foregroundStyle(tint)
            
            Text(title)
                .semibold()
            
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

#Preview {
    BillingAccountRow("Email", icon: "envelope.fill", tint: .blue, value: "test@example.com")
        .padding()
        .darkSchemePreferred()
}
