import SwiftUI

struct BillingActionRow: View {
    private let title: LocalizedStringKey
    private let icon: String
    private let tint: Color
    private let role: ButtonRole?
    private let action: () -> Void
    
    init(_ title: LocalizedStringKey, icon: String, tint: Color, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(role: role, action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(32)
                    .glassEffect(.regular.tint(tint.opacity(0.15)), in: .rect(cornerRadius: 10))
                    .foregroundStyle(tint)
                
                Text(title)
                    .subheadline(.semibold)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .footnote()
                    .secondary()
            }
        }
        .buttonStyle(.plain)
    }
}
