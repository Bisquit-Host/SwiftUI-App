import ScrechKit

struct CredentialsButton: View {
    @State private var sheetUpdateEmail = false
    @State private var sheetUpdatePassword = false
    
    var body: some View {
        Menu {
            MenuButton("E-mail", icon: "envelope.open") {
                sheetUpdateEmail = true
            }
            
            MenuButton("Password", icon: "key") {
                sheetUpdatePassword = true
            }
        } label: {
            HStack {
                Text("Update credentials")
                
                Spacer()
                
                Image(systemName: "chevron.forward")
                    .secondary()
            }
        }
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
