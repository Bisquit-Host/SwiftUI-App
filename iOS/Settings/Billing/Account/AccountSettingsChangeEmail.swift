import SwiftUI

struct AccountSettingsChangeEmail: View {
    @Environment(BillingSettingsVM.self) private var vm
    
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    @State private var alertChangeEmail = false
    
    var body: some View {
        @Bindable var vm = vm
        
        GlassyButton("Email", subtitle: user.email, icon: "envelope.fill", tint: .indigo) {
            vm.newEmail = user.email
            alertChangeEmail = true
        }
        .alert("Change email", isPresented: $alertChangeEmail) {
            TextField("New email", text: $vm.newEmail)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .limitInputLength($vm.newEmail, length: 100)
            
            Button("Change", role: .confirmy, action: changeEmail)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will receive a confirmation email to complete the change")
        }
    }
    
    private func changeEmail() {
        Task {
            await vm.changeEmail()
        }
    }
}

//#Preview {
//    AccountSettingsChangeEmail()
//}
