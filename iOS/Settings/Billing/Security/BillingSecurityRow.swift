import SwiftUI

struct BillingSecurityRow: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    private let title: LocalizedStringKey
    private let icon: String
    private let enabled: Bool
    private let enabledText: LocalizedStringKey
    private let disabledText: LocalizedStringKey
    private let onEnabledTap: (() -> Void)?
    private let onDisabledTap: (() -> Void)?
    
    init(_ title: LocalizedStringKey, icon: String, enabled: Bool, enabledText: LocalizedStringKey, disabledText: LocalizedStringKey, onEnabledTap: (() -> Void)? = nil, onDisabledTap: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.enabled = enabled
        self.enabledText = enabledText
        self.disabledText = disabledText
        self.onEnabledTap = onEnabledTap
        self.onDisabledTap = onDisabledTap
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(32)
#if !os(visionOS)
                .glassEffect(.regular.tint(Color(enabled ? .green : .red).opacity(0.15)), in: .rect(cornerRadius: 10))
#endif
                .foregroundStyle(enabled ? .green : .red)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .subheadline(.semibold)
                
                if differentiateWithoutColor {
                    Text(enabled ? String(localized: "Enabled") : String(localized: "Disabled"))
                }
            }
            
            Spacer()
            
            Group {
                if enabled {
                    Button(enabledText) {
                        onEnabledTap?()
                    }
                } else {
                    Button(disabledText) {
                        onDisabledTap?()
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
