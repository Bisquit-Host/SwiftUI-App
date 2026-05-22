import SwiftUI

struct Login2FASheetParent: View {
    @Environment(LoginVM.self) private var vm
    
    @Binding var `2FACode`: String
    @Binding var pending2FAToken: String?
    var handleAuthResponse: @MainActor (BillingSessionAuthResponse) async -> Void
    @State private var successHapticTrigger = false
    @State private var loginAttempts = 0
    
    var body: some View {
        @Bindable var vm = vm
        
        NavigationStack {
            Login2FASheet(
                code: `$2FACode`,
                isVerifying: $vm.isVerifying2FA,
                onVerify: verifyTwoFA,
                loginAttempts: loginAttempts
            )
            .scenePadding()
        }
        .hapticOn(successHapticTrigger, as: .success)
    }
    
    private func verifyTwoFA() async {
        guard let pending2FAToken else {
            return
        }
        
        guard let response = await vm.verify2FA(code: `2FACode`, token: pending2FAToken) else {
            loginAttempts += 1
            return
        }
        
        successHapticTrigger.toggle()
        
        try? await Task.sleep(for: .seconds(0.5))
        await handleAuthResponse(response)
    }
}
