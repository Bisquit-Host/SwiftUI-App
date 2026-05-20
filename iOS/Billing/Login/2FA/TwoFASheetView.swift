import SwiftUI

struct TwoFASheetView: View {
    @Binding var code: String
    @Binding var isVerifying: Bool
    var onVerify: () async -> Void
    var loginAttempts = 0
    
    private let totpCodeLength = 6
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 10) {
                Text("Enter 2FA code")
                    .title3()
                    .frame(maxWidth: .infinity)
                
                Text("Enter the 6-digit code from your authenticator app to finish signing in")
                    .secondary()
                    .footnote()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            
            TOTPInputField(code: $code, codeLength: totpCodeLength, loginAttempts: loginAttempts)
            
            Spacer()
        }
        .onChange(of: code) { oldValue, newValue in
            let filtered = newValue.filter(\.isNumber)
            let clamped = String(filtered.prefix(totpCodeLength))
            
            if clamped != newValue {
                code = clamped
            }
            
            guard oldValue.count < totpCodeLength, clamped.count == totpCodeLength, !isVerifying else { return }
            
            Task {
                await onVerify()
            }
        }
    }
}

#Preview {
    @Previewable @State var `2FACode` = ""
    @Previewable @State var pending2FAToken: String? = ""
    
    Login2FASheetParent(`2FACode`: `$2FACode`, pending2FAToken: $pending2FAToken) { _ in }
        .environment(LoginVM())
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
