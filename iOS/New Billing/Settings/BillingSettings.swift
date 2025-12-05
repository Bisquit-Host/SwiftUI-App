import SwiftUI

struct BillingSettings: View {
    @State private var vm = BillingSettingsVM()
    @State private var twoFAVM = BillingTwoFAVM()
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    @Binding private var user: BillingUser?
    
    init(_ user: Binding<BillingUser?>) {
        _user = user
    }
    
    @State private var showPasswordSheet = false
    @State private var showTwoFASheet = false
    @State private var confirmDisableTwoFA = false
    @State private var isDisablingTwoFA = false
    @State private var disableError: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let user {
                    VStack(alignment: .leading, spacing: 16) {
                        BillingAccountSection(user)
                        
                        BillingSectionCard("Security") {
                            BillingSecurityRow("2FA", icon: "shield.fill", enabled: user.twoFa, enabledText: "Disable", disabledText: "Connect") {
                                confirmDisableTwoFA = true
                            } onDisabledTap: {
                                showTwoFASheet = true
                            }
                            
                            BillingSecurityRow("Password", icon: "key.fill", enabled: user.hasPassword, enabledText: "Change", disabledText: "Set") {
                                showPasswordSheet = true
                            } onDisabledTap: {
                                showPasswordSheet = true
                            }
                            
                            PasskeyListNavLink()
                        }
                        
                        AuthAppsSection(user: $user)
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
        .scrollIndicators(.never)
        .task {
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
        .sheet($showTwoFASheet) {
            NavigationStack {
                BillingTwoFASetupSheet {
                    await dashboardVM.fetchUserInfo()
                }
                .environment(twoFAVM)
            }
        }
        .environment(vm)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
        }
        .alert("Disable 2FA?", isPresented: $confirmDisableTwoFA) {
            Button("Cancel", role: .cancel) {}
            
            Button("Disable", role: .destructive) {
                disableTwoFA()
            }
            .disabled(isDisablingTwoFA)
        } message: {
            if let disableError {
                Text(disableError)
            } else {
                Text("You will remove extra protection for your account")
            }
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
    
    private func disableTwoFA() {
        guard !isDisablingTwoFA else { return }
        
        isDisablingTwoFA = true
        disableError = nil
        
        Task {
            let success = await twoFAVM.disable()
            isDisablingTwoFA = false
            
            if success {
                await dashboardVM.fetchUserInfo()
            } else {
                disableError = twoFAVM.error
                confirmDisableTwoFA = true
            }
        }
    }
}

#Preview {
    BillingSettings(.constant(.preview))
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
