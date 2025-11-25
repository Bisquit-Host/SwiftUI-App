import ScrechKit

struct DisablePasswordCard: View {
    @Binding var password: String
    var onDisable: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Confirm with password")
                .semibold()
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding(.vertical, 14)
                .padding(.horizontal)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
            
            Button(role: .destructive) {
                onDisable()
            } label: {
                Text("Disable 2FA")
                    .semibold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.glassProminent)
            .tint(.red)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
    }
}
