import SwiftUI

struct BillingSettings: View {
    @State private var vm = BillingSettingsVM()
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @Environment(BillingOAuthVM.self) private var oauthVM
    
    @Binding private var user: BillingUser?
    
    init(_ user: Binding<BillingUser?>) {
        _user = user
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                if let user {
                    VStack(alignment: .leading, spacing: 16) {
                        BillingAccountSection(user)
                        
                        BillingSectionCard("Security") {
                            BillingSecurityRow("2FA", icon: "shield.fill", enabled: user.twoFa, enabledText: "Disable", disabledText: "Connect")
                            BillingSecurityRow("Password", icon: "key.fill", enabled: user.hasPassword, enabledText: "Change", disabledText: "Set")

                            NavigationLink {
                                BillingPasskeysView()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "key.fill")
                                        .frame(32)
                                        .glassEffect(.regular.tint(Color.blue.opacity(0.15)), in: .rect(cornerRadius: 10))
                                        .foregroundStyle(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Passkeys")
                                            .subheadline(.semibold)
                                        Text("Use passkeys to sign in without a password")
                                            .footnote()
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .footnote()
                                        .secondary()
                                }
                                .contentShape(.rect)
                            }
                        }
                        
                        BillingAuthAppsSection(user: $user)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut, value: user)
                }
                
                BillingSectionCard("Debug") {
                    BillingToggleRow("Test billing", icon: "testtube.2", tint: .purple, isOn: $store.testBilling)
                    
                    BillingActionRow("Log out", icon: "rectangle.portrait.and.arrow.right", tint: .red, role: .destructive) {
                        logout()
                    }
                }
            }
        }
        .padding()
        .environment(vm)
        .refreshable {
            await dashboardVM.fetchUserInfo()
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
        }
    }
    
    private func logout() {
        dismiss()
        
        Task {
            try await Task.sleep(for: .seconds(0.5))
            
            withAnimation {
                store.testAccessToken = ""
            }
        }
    }
}

#Preview {
    BillingSettings(.constant(.preview))
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
