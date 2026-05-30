import ScrechKit

struct DisablePasswordCard: View {
    @Binding var password: String
    var onDisable: () -> Void
    
    var body: some View {
        Section {
            SecureField("Password", text: $password)
                .textContentType(.password)
            
            Button("Disable 2FA", systemImage: "lock.slash", role: .destructive, action: onDisable)
                .disabled(password.isEmpty)
        } header: {
            Text("Confirm with password")
        } footer: {
            Text("This only changes Pterodactyl login security")
        }
    }
}
