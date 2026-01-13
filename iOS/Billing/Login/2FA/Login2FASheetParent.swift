import SwiftUI
import BisquitoNet

struct Login2FASheetParent: View {
    @Environment(LoginVM.self) private var vm
    
    @Binding var `2FACode`: String
    @Binding var pending2FAToken: String?
    var handleAuthResponse: @MainActor (BillingLoginResponse) async -> Void
    
    var body: some View {
        @Bindable var vm = vm
        
        NavigationStack {
            TwoFASheetView(code: `$2FACode`, isVerifying: $vm.isVerifying2FA, onVerify: verifyTwoFA)
                .padding()
                .navigationTitle("Enter 2FA code")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func verifyTwoFA() async {
        guard
            let pending2FAToken,
            let response = await vm.verify2FA(code: `2FACode`, token: pending2FAToken)
        else {
            return
        }
        
        await handleAuthResponse(response)
    }
}
