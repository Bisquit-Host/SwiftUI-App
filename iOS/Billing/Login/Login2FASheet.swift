import SwiftUI

struct Login2FASheet: View {
    @Environment(LoginVM.self) private var vm
    
    @Binding private var `2FACode`: String
    private var verifyAction: () async -> Void
    
    init(_ `2FACode`: Binding<String>, verifyAction: @escaping () async -> Void) {
        _2FACode = `2FACode`
        self.verifyAction = verifyAction
    }
    
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
                        await verifyAction()
                    }
                }
            
            Button {
                Task {
                    await verifyAction()
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
}

#Preview {
    Login2FASheet(.constant("123456")) {}
        .padding()
        .environment(LoginVM())
}
