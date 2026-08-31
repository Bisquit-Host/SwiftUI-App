import SwiftUI

struct AuthSettingsAppCard: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @State private var alertDisconnect = false
    
    private let title: LocalizedStringKey
    private let icon: String
    private let enabled: Bool
    private let isAvailable: Bool
    private let isLoading: Bool
    private let onConnect: (() async -> Void)?
    private let onDisconnect: (() async -> Void)?
    
    init(
        _ title: LocalizedStringKey,
        icon: String,
        enabled: Bool,
        isAvailable: Bool = true,
        isLoading: Bool = false,
        onConnect: (() async -> Void)? = nil,
        onDisconnect: (() async -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.enabled = enabled
        self.isAvailable = isAvailable
        self.isLoading = isLoading
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
    }
    
    var body: some View {
        let statusColor: Color = isAvailable ? (enabled ? .green : .red) : .gray
        let tint = statusColor.opacity(0.15)
        
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(32)
#if !os(visionOS)
                .glassEffect(.regular.tint(tint), in: .rect(cornerRadius: 10))
#endif
                .foregroundStyle(statusColor)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .subheadline(.semibold)
                
                if differentiateWithoutColor {
                    Text(statusText)
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
                        alertDisconnect = true
                    }
                    .disabled(onDisconnect == nil || !isAvailable)
                } else {
                    Button("Connect") {
                        Task {
                            await onConnect?()
                        }
                    }
                    .disabled(onConnect == nil || !isAvailable)
                }
            }
            .secondary()
            .footnote()
        }
        .opacity(isAvailable ? 1 : 0.45)
        .disabled(!isAvailable)
        .accessibilityHint(isAvailable ? "" : "Unavailable")
        .alert("Disconnect OAuth service?", isPresented: $alertDisconnect) {
            Button("Disconnect", role: .destructive, action: disconnect)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will need to reconnect this service to use it again")
        }
    }

    private var statusText: String {
        if !isAvailable {
            return String(localized: "Unavailable")
        }

        return enabled ? String(localized: "Enabled") : String(localized: "Disabled")
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
