import SwiftUI

struct GlassyButton: View {
    private let title: LocalizedStringKey
    private let subtitle: String?
    private let icon: String
    private let tint: Color
    private let action: (() -> Void)?
    
    init(_ title: LocalizedStringKey, subtitle: String?, icon: String, tint: Color, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
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
                
                if let subtitle {
                    Text(subtitle)
                        .secondary()
                        .footnote()
                        .numericTransition()
                        .lineLimit(2)
                }
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
    GlassyButton("Email", subtitle: "test@example.com", icon: "envelope.fill", tint: .blue)
        .padding()
        .darkSchemePreferred()
}
