import SwiftUI

struct CredentialsButton: View {
    @Environment(AccountVM.self) private var vm
    
    @State private var sheetUpdateEmail = false
    @State private var sheetUpdatePassword = false
    
    var body: some View {
        if let account = vm.account {
            GlassyButton("Email", subtitle: account.email, icon: "envelope.fill", tint: .blue) {
                sheetUpdateEmail = true
            }
            .sheet($sheetUpdateEmail) {
                CredentialsView("email")
            }
            
            GlassyButton("Password", icon: "person.fill", tint: .cyan) {
                sheetUpdatePassword = true
            }
            .sheet($sheetUpdatePassword) {
                CredentialsView("password")
            }
        }
    }
}

#Preview {
    List {
        CredentialsButton()
    }
    .darkSchemePreferred()
    .environment(AccountVM())
}
