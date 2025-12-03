import SwiftUI

struct BillingAccountSection: View {
    @Environment(BillingSettingsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
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
            BillingAvatarHeader(user)
            
            Divider()
            
            BillingAccountRow("Email", icon: "envelope.fill", tint: .blue, value: user.email) {
                vm.newEmail = user.email
                alertEmail = true
            }
            
            BillingAccountRow("Name", icon: "person.fill", tint: .cyan, value: user.name) {
                vm.newName = user.name
                alertRename = true
            }
            
            BillingAccountRow("Login", icon: "at", tint: .indigo, value: user.login) {
                vm.newLogin = user.login
                alertLogin = true
            }
            
            BillingAccountRow("Language", icon: "character.cursor.ibeam", tint: .mint, value: user.lang.uppercased())
            BillingAccountRow("Currency", icon: "dollarsign", tint: .yellow, value: user.currency)
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
    
}

#Preview {
    BillingAccountSection(.preview)
        .darkSchemePreferred()
        .environment(BillingSettingsVM())
        .environment(BillingDashboardVM())
}
