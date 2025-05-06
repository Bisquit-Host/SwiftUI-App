import SwiftUI

struct CredentialsButton: View {
    @State private var sheetUpdateEmail = false
    @State private var sheetUpdatePassword = false
    
    var body: some View {
        Section {
            Button("Change E-mail") {
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
        .transparentSection()
        .primary()
    }
}

#Preview {
    List {
        CredentialsButton()
    }
}
