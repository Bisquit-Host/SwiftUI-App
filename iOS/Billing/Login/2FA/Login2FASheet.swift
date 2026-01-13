import SwiftUI
import BisquitoNet

struct TwoFASheetView: View {
    @Binding var code: String
    @Binding var isVerifying: Bool
    var onVerify: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter the 6-digit code from your authenticator app to finish signing in")
                .secondary()
                .footnote()
            
            TextField("123456", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .onSubmit {
                    Task {
                        await onVerify()
                    }
                }
            
            Button {
                Task {
                    await onVerify()
                }
            } label: {
                if isVerifying {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Verify and continue")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(code.trimmingCharacters(in: .whitespaces).count < 6 || isVerifying)
        }
    }
}

struct Login2FASheet: View {
    @Environment(LoginVM.self) private var vm
    
    @Binding var `2FACode`: String
    @Binding var pending2FAToken: String?
    var handleAuthResponse: @MainActor (BillingLoginResponse) async -> Void
    
    var body: some View {
        TwoFASheetView(
            code: `$2FACode`,
            isVerifying: Binding(
                get: { vm.isVerifying2FA },
                set: { _ in }
            ),
            onVerify: verifyTwoFA
        )
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
