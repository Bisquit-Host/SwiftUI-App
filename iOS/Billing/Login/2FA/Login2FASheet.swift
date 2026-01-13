import SwiftUI

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

#Preview {
    @Previewable @State var `2FACode` = ""
    @Previewable @State var pending2FAToken: String? = ""
    
    Login2FASheetParent(`2FACode`: `$2FACode`, pending2FAToken: $pending2FAToken) { _ in }
        .environment(LoginVM())
}
