import SwiftUI

struct BillingAccountSection: View {
    @Environment(BillingSettingsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    @State private var alertRename = false
    
    var body: some View {
        @Bindable var vm = vm
        
        BillingSectionCard("Account") {
            BillingAccountRow("Email", icon: "envelope.fill", tint: .blue, value: user.email) {
                
            }
            
            BillingAccountRow("Name", icon: "person.fill", tint: .cyan, value: user.name) {
                vm.newName = user.name
                alertRename = true
            }
            
            BillingAccountRow("Language", icon: "character.cursor.ibeam", tint: .mint, value: user.lang.uppercased()) {
                
            }
            
            BillingAccountRow("Currency", icon: "dollarsign", tint: .yellow, value: user.currency)
        }
        .alert("Change name", isPresented: $alertRename) {
            TextField("New name", text: $vm.newName)
                .autocorrectionDisabled()
                .limitInputLength($vm.newName, length: 100)
            
            Button("Change", role: .destructive) {
                change()
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
}

#Preview {
    BillingAccountSection(.preview)
        .darkSchemePreferred()
        .environment(BillingSettingsVM())
        .environment(BillingDashboardVM())
}
