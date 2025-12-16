import SwiftUI
import PteroNet

struct BillingSettings: View {
    @State private var vm = BillingSettingsVM()
    @State private var `2FAVM` = Billing2FAVM()
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
                        
                        AuthAppsSection($user)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut, value: user)
                }
                
                BillingSectionCard("Debug") {
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
                Billing2FASetup {
                    await dashboardVM.fetchUserInfo()
                }
                .environment(`2FAVM`)
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
            Text("You will remove extra protection for your account")
        }
    }
    
    private func logout() {
        dismiss()
        
        Task {
            try await Task.sleep(for: .seconds(0.5))
            
            if !Keychain.delete(key: "access_token") {
                print("Error logging out")
            }
            
            store.testExpiresIn = 0
            store.accessToken = nil
            store.lastBillingTokenRefresh = nil
            Keychain.delete(key: "refresh_token")
            
            withAnimation {
                store.updateAccessToken()
            }
        }
    }
    
    private func disableTwoFA() {
        guard !isDisablingTwoFA else { return }
        isDisablingTwoFA = true
        
        Task {
            let success = await `2FAVM`.disable()
            isDisablingTwoFA = false
            
            if success {
                await dashboardVM.fetchUserInfo()
            } else {
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
