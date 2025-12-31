import SwiftUI

struct OAuth2FASheet: View {
    @Environment(OAuthVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter the 6-digit code from your authenticator app to finish signing in")
                .secondary()
                .footnote()
            
            TextField("123456", text: $vm.twoFACode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .onSubmit {
                    Task {
                        await vm.verifyTwoFA()
                    }
                }
            
            Button {
                Task {
                    await vm.verifyTwoFA()
                }
            } label: {
                if vm.isVerifyingTwoFA {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Verify and continue")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.twoFACode.trimmingCharacters(in: .whitespaces).count < 6 || vm.isVerifyingTwoFA)
        }
    }
}

#Preview {
    OAuth2FASheet()
        .padding()
        .environment(OAuthVM())
}
