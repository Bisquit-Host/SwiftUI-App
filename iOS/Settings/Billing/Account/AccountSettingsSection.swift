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
            
            GlassyButton("Email", subtitle: user.email, icon: "envelope.fill", tint: .indigo) {
                vm.newEmail = user.email
                alertEmail = true
            }
            
            GlassyButton("Name", subtitle: user.name, icon: "person.fill", tint: .indigo) {
                vm.newName = user.name
                alertRename = true
            }
            
            GlassyButton("Login", subtitle: user.login, icon: "at", tint: .indigo) {
                vm.newLogin = user.login
                alertLogin = true
            }
            
            GlassyButton("Language", subtitle: user.lang.uppercased(), icon: "character.cursor.ibeam", tint: .indigo)
            GlassyButton("Currency", subtitle: user.currency.rawValue, icon: user.currency.sfSymbol, tint: .yellow)
            
            GlassyActionCard("Log out", icon: "rectangle.portrait.and.arrow.right", tint: .red, role: .destructive) {
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
            
            Button("Change", role: .confirm, action: changeEmail)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will receive a confirmation email to complete the change")
        }
        .alert("Change login", isPresented: $alertLogin) {
            TextField("New login", text: $vm.newLogin)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .limitInputLength($vm.newLogin, length: 100)
            
            Button("Change", role: .confirm, action: changeLogin)
            Button("Cancel", role: .cancel) {}
        }
        .alert("Change name", isPresented: $alertRename) {
            TextField("New name", text: $vm.newName)
                .autocorrectionDisabled()
                .limitInputLength($vm.newName, length: 100)
            
            Button("Change", role: .confirm) {
                if vm.newName != user.name {
                    change()
                }
            }
            
            Button("Cancel", role: .cancel) {}
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
