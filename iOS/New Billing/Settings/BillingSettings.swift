import SwiftUI

struct BillingSettings: View {
    @State private var vm = BillingSettingsVM()
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    @Binding private var user: BillingUser?
    
    init(_ user: Binding<BillingUser?>) {
        _user = user
    }
    
    @State private var showPasswordSheet = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                if let user {
                    VStack(alignment: .leading, spacing: 16) {
                        BillingAccountSection(user)
                        
                        BillingSectionCard("Security") {
                            BillingSecurityRow("2FA", icon: "shield.fill", enabled: user.twoFa, enabledText: "Disable", disabledText: "Connect")
                            
                            BillingSecurityRow("Password", icon: "key.fill", enabled: user.hasPassword, enabledText: "Change", disabledText: "Set") {
                                showPasswordSheet = true
                            } onDisabledTap: {
                                showPasswordSheet = true
                            }
                            
                            BillingSettingsPasskeys()
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
            .padding()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .refreshableTask {
            await dashboardVM.fetchUserInfo()
        }
        .sheet($showPasswordSheet) {
            NavigationStack {
                if let user {
                    BillingPasswordSheet(hasPassword: user.hasPassword) {
                        await dashboardVM.fetchUserInfo()
                    }
                }
            }
        }
        .environment(vm)
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
