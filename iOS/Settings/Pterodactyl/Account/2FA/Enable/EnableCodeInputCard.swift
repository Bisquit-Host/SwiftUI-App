import ScrechKit

struct EnableCodeInputCard: View {
    @Binding var code: String
    @Binding var password: String
    var onVerify: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter the 6-digit code")
                .semibold()
            
            TextField("123 456", text: $code)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
                .monospaced()
                .padding(.vertical, 14)
                .padding(.horizontal)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding(.vertical, 14)
                .padding(.horizontal)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
            
            Button(action: onVerify) {
                Text("Verify & Enable")
                    .semibold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
#if !os(visionOS)
            .buttonStyle(.glassProminent)
#endif
            .tint(.green)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
    }
}
