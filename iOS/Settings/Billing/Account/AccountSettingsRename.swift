import SwiftUI

struct AccountSettingsRename: View {
    @Environment(BillingSettingsVM.self) private var vm
    @Environment(DashboardViewVM.self) private var dashboardVM
    
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    @State private var alertRename = false
    
    var body: some View {
        @Bindable var vm = vm
        
        GlassyButton("Name", subtitle: user.name, icon: "person.fill", tint: .indigo) {
            vm.newName = user.name
            alertRename = true
        }
        .alert("Change name", isPresented: $alertRename) {
            TextField("New name", text: $vm.newName)
                .autocorrectionDisabled()
                .limitInputLength($vm.newName, length: 100)
            
            Button("Change", role: .confirmy, action: rename)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func rename() {
        Task {
            if vm.newName != user.name {
                await vm.changeName {
                    await dashboardVM.fetchUserInfo()
                }
            }
        }
    }
}

//#Preview {
//    AccountSettingsRename()
//}
