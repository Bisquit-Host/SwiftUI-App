import SwiftUI

struct AccountSettingsRow: View {
    private let title: LocalizedStringKey
    private let icon: String
    private let tint: Color
    private let value: String
    private let action: (() -> Void)?
    
    init(_ title: LocalizedStringKey, icon: String, tint: Color, value: String, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.value = value
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(32)
                .glassEffect(.regular.tint(tint.opacity(0.15)), in: .rect(cornerRadius: 10))
                .foregroundStyle(tint)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .subheadline(.semibold)
                
                Text(value)
                    .secondary()
                    .footnote()
                    .numericTransition()
                    .lineLimit(2)
            }
            
            Spacer()
            
            if let action {
                Button("Change") {
                    action()
                }
                .footnote()
                .secondary()
            }
        }
    }
}

#Preview {
    AccountSettingsRow("Email", icon: "envelope.fill", tint: .blue, value: "test@example.com")
        .padding()
        .darkSchemePreferred()
}
