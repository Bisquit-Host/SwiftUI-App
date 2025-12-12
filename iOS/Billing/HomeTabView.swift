import SwiftUI

struct HomeTabView: View {
    @State private var securityTasks = SecurityTasks()
    @EnvironmentObject private var store: ValueStore
    
    @State private var showBilling = false
    
    var body: some View {
        ZStack {
#if os(iOS)
            if showBilling {
                billingRoot
            } else {
                pterodactylRoot
            }
#else
            pterodactylRoot
#endif
        }
        .overlay(alignment: .bottom) {
            FloatingTabBar(showBilling: $showBilling)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
        }
        .environment(securityTasks)
        .onFirstAppear {
            await securityTasks.startCheck()
        }
        .fullScreenCover($securityTasks.alertUpdate) {
            RequireUpdateView()
        }
    }
#if os(iOS)
    @ViewBuilder private var billingRoot: some View {
        if (store.accessToken?.isEmpty ?? true) {
            BillingLogin()
                .withNavDestinations()
        } else {
            BillingDashboard()
                .withNavDestinations()
        }
    }
#endif
    @ViewBuilder private var pterodactylRoot: some View {
        if store.isApiKeyValid {
            ServerList()
                .withNavDestinations()
        } else {
            StartPage()
                .withNavDestinations()
        }
    }
}

struct FloatingTabBar: View {
    @Binding var showBilling: Bool
    
    var body: some View {
        HStack(spacing: 10) {
#if os(iOS)
            tabButton("Billing", systemImage: "person.crop.circle", isSelected: showBilling) {
                withAnimation(.snappy) {
                    showBilling = true
                }
            }
#endif
            tabButton("Pterodactyl", systemImage: "externaldrive", isSelected: !showBilling) {
                withAnimation(.snappy) {
                    showBilling = false
                }
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(.white.opacity(0.20), lineWidth: 1)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.22),
                                    .white.opacity(0.06),
                                    .white.opacity(0.16)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)
                        .allowsHitTesting(false)
                }
                .shadow(radius: 14, y: 8)
        }
        .compositingGroup()
    }
    
    private func tabButton(_ title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(.thinMaterial)
                        .overlay {
                            Capsule()
                                .strokeBorder(.white.opacity(0.22), lineWidth: 1)
                        }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeTabView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
