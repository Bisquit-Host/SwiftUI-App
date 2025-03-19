import SwiftUI

struct CredentialsButton: View {
    @State private var sheetUpdateEmail = false
    @State private var sheetUpdatePassword = false
    
    var body: some View {
        Section {
            Button("Change E-mail") {
                sheetUpdateEmail = true
            }
            
            Button("Change Password") {
                sheetUpdatePassword = true
            }
        }
        .transparentSection()
        .foregroundStyle(.primary)
        .sheet($sheetUpdateEmail) {
            CredentialsView("email")
        }
        .sheet($sheetUpdatePassword) {
            CredentialsView("password")
        }
    }
}

#Preview {
    List {
        CredentialsButton()
    }
}
