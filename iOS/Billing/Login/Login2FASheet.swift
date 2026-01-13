import SwiftUI
import BisquitoNet

struct Login2FASheet: View {
    @Environment(LoginVM.self) private var vm
    
    @Binding var `2FACode`: String
    @Binding var pending2FAToken: String?
    var handleAuthResponse: @MainActor (BillingLoginResponse) async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter the 6-digit code from your authenticator app to finish signing in")
                .secondary()
                .footnote()
            
            TextField("123456", text: $2FACode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .onSubmit {
                    Task {
                        await verifyTwoFA()
                    }
                }
            
            Button {
                Task {
                    await verifyTwoFA()
                }
            } label: {
                if vm.isVerifying2FA {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Verify and continue")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(`2FACode`.trimmingCharacters(in: .whitespaces).count < 6 || vm.isVerifying2FA)
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

//#Preview {
//    Login2FASheet(.constant("123456")) {}
//        .padding()
//        .environment(LoginVM())
//}
