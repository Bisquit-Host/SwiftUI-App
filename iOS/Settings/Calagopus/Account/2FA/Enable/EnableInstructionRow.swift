import ScrechKit

struct EnableInstructionRow: View {
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
                .foregroundStyle(.white)
                .background(.blue.gradient.opacity(0.9), in: .rect(cornerRadius: 8))
            
            Text(text)
                .secondary()
        }
    }
}
