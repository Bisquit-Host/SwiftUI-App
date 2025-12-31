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
            
            Button(role: .destructive, action: onDisable) {
                Text("Disable 2FA")
                    .semibold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .tint(.red)
#if !os(visionOS)
            .buttonStyle(.glassProminent)
#endif
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
    }
}
