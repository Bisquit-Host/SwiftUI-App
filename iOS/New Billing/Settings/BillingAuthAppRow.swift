import SwiftUI

struct BillingAuthAppRow: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    private let title: String
    private let icon: String
    private let enabled: Bool
    
    init(_ title: String, icon: String, enabled: Bool) {
        self.title = title
        self.icon = icon
        self.enabled = enabled
    }
    
    var body: some View {
        let tint = Color(enabled ? .green : .red).opacity(0.15)
        
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(32)
                .glassEffect(.regular.tint(tint), in: .rect(cornerRadius: 10))
                .foregroundStyle(enabled ? .green : .red)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .subheadline(.semibold)
                
                if differentiateWithoutColor {
                    Text(enabled ? "Enabled" : "Disabled")
                }
            }
            
            Spacer()
            
            Group {
                if enabled {
                    Button("Disconnect") {
                        
                    }
                } else {
                    Button("Connect") {
                        
                    }
                }
            }
            .secondary()
            .footnote()
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        BillingAuthAppRow("2FA", icon: "lock.shield.fill", enabled: true)
        BillingAuthAppRow("Password", icon: "key.fill", enabled: false)
    }
    .padding()
    .darkSchemePreferred()
}
