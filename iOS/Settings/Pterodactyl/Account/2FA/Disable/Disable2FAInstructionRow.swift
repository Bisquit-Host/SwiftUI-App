import ScrechKit

struct Disable2FAInstructionRow: View {
    let text: LocalizedStringKey
    let systemImage: String
    
    init(_ text: LocalizedStringKey, systemImage: String) {
        self.text = text
        self.systemImage = systemImage
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .bold()
                .frame(30)
                .foregroundStyle(.red)
            
            Text(text)
                .secondary()
        }
    }
}
