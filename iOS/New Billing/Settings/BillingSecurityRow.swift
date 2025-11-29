import SwiftUI

struct BillingSecurityRow: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    private let title: String
    private let icon: String
    private let enabled: Bool
    private let enabledText: String
    private let disabledText: String
    
    init(_ title: String, icon: String, enabled: Bool, enabledText: String, disabledText: String) {
        self.title = title
        self.icon = icon
        self.enabled = enabled
        self.enabledText = enabledText
        self.disabledText = disabledText
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(32)
                .glassEffect(.regular.tint(Color(enabled ? .green : .red).opacity(0.15)), in: .rect(cornerRadius: 10))
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
                    Button(enabledText) {
                        
                    }
                } else {
                    Button(disabledText) {
                        
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
        BillingSecurityRow("2FA", icon: "lock.shield.fill", enabled: true, enabledText: "Disable", disabledText: "Connect")
        BillingSecurityRow("Password", icon: "key.fill", enabled: false, enabledText: "Change", disabledText: "Set")
    }
    .padding()
    .darkSchemePreferred()
}
