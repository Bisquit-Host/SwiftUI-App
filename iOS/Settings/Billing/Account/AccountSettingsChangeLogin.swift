import SwiftUI

struct AccountSettingsChangeLogin: View {
    @Environment(BillingSettingsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    @State private var alertChangeLogin = false
    
    var body: some View {
        @Bindable var vm = vm
        
        GlassyButton("Login", subtitle: user.login, icon: "at", tint: .indigo) {
            vm.newLogin = user.login
            alertChangeLogin = true
        }
        .alert("Change login", isPresented: $alertChangeLogin) {
            TextField("New login", text: $vm.newLogin)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .limitInputLength($vm.newLogin, length: 100)
            
            Button("Change", role: .confirm, action: changeLogin)
            Button("Cancel", role: .cancel) {}
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

//#Preview {
//    AccountSettingsChangeLogin()
//}
