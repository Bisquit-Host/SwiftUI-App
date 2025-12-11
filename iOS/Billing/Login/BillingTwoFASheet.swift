import SwiftUI

struct BillingTwoFASheet: View {
    @Bindable var vm: BillingLoginVM
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
            
            if let twoFAError = vm.twoFAError {
                Text(twoFAError)
                    .foregroundStyle(.red)
                    .footnote()
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
    BillingTwoFASheet(vm: BillingLoginVM(), twoFACode: .constant("123456")) {}
        .padding()
}
