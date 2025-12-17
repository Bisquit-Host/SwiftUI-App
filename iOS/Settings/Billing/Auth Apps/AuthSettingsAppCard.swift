import SwiftUI

struct AuthSettingsAppCard: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    private let title: LocalizedStringKey
    private let icon: String
    private let enabled: Bool
    private let isLoading: Bool
    private let onConnect: (() -> Void)?
    private let onDisconnect: (() async -> Void)?
    
    init(
        _ title: LocalizedStringKey,
        icon: String,
        enabled: Bool,
        isLoading: Bool = false,
        onConnect: (() -> Void)? = nil,
        onDisconnect: (() async -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.enabled = enabled
        self.isLoading = isLoading
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
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
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.secondary)
                        .padding(.horizontal, 8)
                } else if enabled {
                    Button("Disconnect") {
                        disconnect()
                    }
                    .disabled(onDisconnect == nil)
                } else {
                    Button("Connect") {
                        onConnect?()
                    }
                    .disabled(onConnect == nil)
                }
            }
            .secondary()
            .footnote()
        }
    }
    
    private func disconnect() {
        Task {
            await onDisconnect?()
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        AuthSettingsAppCard("2FA", icon: "lock.shield.fill", enabled: true)
        AuthSettingsAppCard("Password", icon: "key.fill", enabled: false)
    }
    .padding()
    .darkSchemePreferred()
}
