import SwiftUI

struct VDSSheetSSHCredentials: View {
    @Binding private var credentials: SSHCredentialsState
    
    init(credentials: Binding<SSHCredentialsState>) {
        _credentials = credentials
    }
    
    var body: some View {
        List {
            Section("Host") {
                TextField("Host", text: $credentials.host)
                    .sshTextFielgStyle()
            }
            
            Section("Port") {
                TextField("Port", text: $credentials.port)
                    .sshTextFielgStyle()
            }
            
            Section("Username"){
                TextField("Username", text: $credentials.username)
                    .sshTextFielgStyle()
            }
            
            Section("Password") {
                SecureField("Password", text: $credentials.password)
                    .sshTextFielgStyle()
            }
        }
        .navigationTitle("SSH Credentials")
        .toolbarTitleDisplayMode(.inline)
        .presentationDetents([.medium])
    }
}
