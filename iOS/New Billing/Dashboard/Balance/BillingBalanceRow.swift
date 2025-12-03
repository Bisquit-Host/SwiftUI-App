import SwiftUI

struct BillingBalanceRow: View {
    private let title: String
    private let icon: String
    private let tint: Color
    private let value: String
    
    init(_ title: String, icon: String, tint: Color, value: String) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.value = value
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .footnote()
                .frame(32)
                .glassEffect(.regular.tint(tint.opacity(0.15)), in: .rect(cornerRadius: 10))
                .foregroundStyle(tint)
            
            Text(title)
                .subheadline(.semibold)
            
            Spacer()
            
            Text(value)
                .rounded()
                .numericTransition()
                .foregroundStyle(title == "Total" ? .primary : .secondary)
                .fontWeight(title == "Total" ? .semibold : .regular)
        }
    }
}

#Preview {
    BillingAccountRow("Email", icon: "envelope.fill", tint: .blue, value: "test@example.com")
        .padding()
        .darkSchemePreferred()
}
