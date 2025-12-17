import SwiftUI
import PteroNet

struct AccountSettingsSection: View {
    @Environment(BillingSettingsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    @State private var alertRename = false
    @State private var alertEmail = false
    @State private var alertLogin = false
    
    var body: some View {
        @Bindable var vm = vm
        
        BillingSectionCard("Account") {
            AccountSettingsHeader(user)
            
            Divider()
            
            AccountSettingsRow("Email", icon: "envelope.fill", tint: .blue, value: user.email) {
                vm.newEmail = user.email
                alertEmail = true
            }
            
            AccountSettingsRow("Name", icon: "person.fill", tint: .cyan, value: user.name) {
                vm.newName = user.name
                alertRename = true
            }
            
            AccountSettingsRow("Login", icon: "at", tint: .indigo, value: user.login) {
                vm.newLogin = user.login
                alertLogin = true
            }
            
            AccountSettingsRow("Currency", icon: "dollarsign", tint: .yellow, value: user.currency.rawValue)
            AccountSettingsRow("Language", icon: "character.cursor.ibeam", tint: .mint, value: user.lang.uppercased())
            
            BillingActionRow("Log out", icon: "rectangle.portrait.and.arrow.right", tint: .red, role: .destructive) {
                logout()
            }
        }
        .alert("Change email", isPresented: $alertEmail) {
            TextField("New email", text: $vm.newEmail)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .limitInputLength($vm.newEmail, length: 100)
            
            Button("Change", role: .destructive) {
                changeEmail()
            }
        } message: {
            Text("You will receive a confirmation email to complete the change")
        }
        .alert("Change login", isPresented: $alertLogin) {
            TextField("New login", text: $vm.newLogin)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .limitInputLength($vm.newLogin, length: 100)
            
            Button("Change", role: .destructive) {
                changeLogin()
            }
        }
        .alert("Change name", isPresented: $alertRename) {
            TextField("New name", text: $vm.newName)
                .autocorrectionDisabled()
                .limitInputLength($vm.newName, length: 100)
            
            Button("Change", role: .destructive) {
                if vm.newName != user.name {
                    change()
                }
            }
        }
    }
    
    private func change() {
        Task {
            await vm.changeName {
                await dashboardVM.fetchUserInfo()
            }
        }
    }
    
    private func changeEmail() {
        Task {
            await vm.changeEmail()
        }
    }
    
    private func changeLogin() {
        Task {
            await vm.changeLogin {
                await dashboardVM.fetchUserInfo()
            }
        }
    }
    
    private func logout() {
        dismiss()
        
        Task {
            try await Task.sleep(for: .seconds(0.5))
            
            if !Keychain.delete(key: "access_token") {
                print("Error logging out")
            }
            
            store.accessTokenExpiresIn = 0
            store.accessToken = nil
            store.lastBillingTokenRefresh = nil
            Keychain.delete(key: "refresh_token")
            
            withAnimation {
                store.updateAccessToken()
            }
        }
    }
}

#Preview {
    AccountSettingsSection(.preview)
        .darkSchemePreferred()
        .environment(BillingSettingsVM())
        .environment(BillingDashboardVM())
}
