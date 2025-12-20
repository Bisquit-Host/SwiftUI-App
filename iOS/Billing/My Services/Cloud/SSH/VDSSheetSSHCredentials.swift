import SwiftUI

struct VDSSheetSSHCredentials: View {
    @Binding private var host: String
    @Binding private var port: String
    @Binding private var username: String
    @Binding private var password: String
    
    init(host: Binding<String>, port: Binding<String>, username: Binding<String>, password: Binding<String>) {
        _host = host
        _port = port
        _username = username
        _password = password
    }
    
    var body: some View {
        List {
            Section("Host") {
                TextField("Host", text: $host)
                    .sshTextFielgStyle()
            }
            
            Section("Port") {
                TextField("Port", text: $port)
                    .sshTextFielgStyle()
            }
            
            Section("Username"){
                TextField("Username", text: $username)
                    .sshTextFielgStyle()
            }
            
            Section("Password") {
                SecureField("Password", text: $password)
                    .sshTextFielgStyle()
            }
        }
        .navigationTitle("SSH Credentials")
        .toolbarTitleDisplayMode(.inline)
        .presentationDetents([.medium])
    }
}
