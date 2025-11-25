import ScrechKit

struct EnableInstructionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How it works")
                .footnote(.semibold)
                .secondary()
            
            VStack(alignment: .leading, spacing: 10) {
                EnableInstructionRow("Scan or open the setup link", systemImage: "qrcode")
                EnableInstructionRow("Your app will generate a 6-digit code", systemImage: "keyboard")
                EnableInstructionRow("Enter the code here to activate", systemImage: "checkmark.seal")
            }
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
        .padding([.bottom, .horizontal])
    }
}
