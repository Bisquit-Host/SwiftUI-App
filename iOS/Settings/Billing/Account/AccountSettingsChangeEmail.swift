import ScrechKit
import BisquitoNet

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
            vm.emailStepUpCode = ""
            vm.emailStepUpPassword = ""
            alertChangeEmail = true
        }
        .alert("Change email", isPresented: $alertChangeEmail) {
            TextField("New email", text: $vm.newEmail)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .limitInputLength($vm.newEmail, length: 100)
            
            if user.twoFa {
                TextField("2FA code", text: $vm.emailStepUpCode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .limitInputLength($vm.emailStepUpCode, length: 6)
            } else if user.hasPassword {
                SecureField("Current password", text: $vm.emailStepUpPassword)
                    .textContentType(.password)
            }
            
            AsyncButton("Change", role: .confirm) {
                await vm.changeEmail(twoFAEnabled: user.twoFa, hasPassword: user.hasPassword)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will receive a confirmation email to complete the change")
        }
    }
}

//#Preview {
//    AccountSettingsChangeEmail()
//}
