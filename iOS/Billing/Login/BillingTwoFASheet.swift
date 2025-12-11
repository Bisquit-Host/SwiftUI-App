import SwiftUI

struct BillingTwoFASheet: View {
    @Environment(BillingLoginVM.self) private var vm
    
    @Binding var twoFACode: String
    var verifyAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter the 6-digit code from your authenticator app to finish signing in")
                .secondary()
                .footnote()
            
            TextField("123456", text: $twoFACode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .onSubmit {
                    verifyAction()
                }
            
            Button(action: verifyAction) {
                if vm.isVerifyingTwoFA {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Verify and continue")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(twoFACode.trimmingCharacters(in: .whitespaces).count < 6 || vm.isVerifyingTwoFA)
        }
    }
}

#Preview {
    BillingTwoFASheet(twoFACode: .constant("123456")) {}
        .padding()
        .environment(BillingLoginVM())
}
