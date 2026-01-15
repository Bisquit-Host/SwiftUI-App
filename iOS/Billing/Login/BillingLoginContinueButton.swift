import SwiftUI

struct BillingLoginContinueButton: View {
    @Environment(LoginVM.self) private var vm
    
    let continueButtonDisabled: Bool
    let isSignUp: Bool
    let performVerification: () -> Void
    
    var body: some View {
        Button(action: performVerification) {
            if vm.isAttesting {
                HStack {
                    ProgressView()
                    Text("Verifying...")
                }
            } else {
                Text(isSignUp ? "Create account" : "Continue")
            }
        }
        .semibold()
        .rounded()
        .disabled(continueButtonDisabled)
        .opacity(continueButtonDisabled ? 0.3 : 1)
        .foregroundStyle(.foreground)
        .frame(minHeight: 50)
        .frame(maxWidth: .infinity)
#if !os(visionOS)
        .glassEffect()
#endif
    }
}
