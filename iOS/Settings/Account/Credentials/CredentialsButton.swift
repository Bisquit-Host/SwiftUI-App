import SwiftUI

struct CredentialsButton: View {
    @State private var sheetUpdateEmail = false
    @State private var sheetUpdatePassword = false
    
    var body: some View {
        Section {
            Button("Change email") {
                sheetUpdateEmail = true
            }
            .sheet($sheetUpdateEmail) {
                CredentialsView("email")
            }
            
            Button("Change Password") {
                sheetUpdatePassword = true
            }
            .sheet($sheetUpdatePassword) {
                CredentialsView("password")
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    List {
        CredentialsButton()
    }
    .darkSchemePreferred()
}
