import SwiftUI

struct DisableTwoFAAlert: ViewModifier {
    @Binding var isPresented: Bool
    var onDisable: (String) -> Void

    @State private var password = ""

    func body(content: Content) -> some View {
        content
            .alert("Disable 2FA?", isPresented: $isPresented) {
                SecureField("Password", text: $password)
                    .textContentType(.password)

                Button("Cancel", role: .cancel) {
                    password = ""
                }

                Button("Disable", role: .destructive) {
                    let submittedPassword = password
                    password = ""
                    onDisable(submittedPassword)
                }
                .disabled(password.isEmpty)
            } message: {
                Text("You will remove extra protection for your account")
            }
            .onChange(of: isPresented) {
                if !isPresented {
                    password = ""
                }
            }
    }
}
