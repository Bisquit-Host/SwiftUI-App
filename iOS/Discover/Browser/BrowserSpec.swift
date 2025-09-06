import ScrechKit

struct BrowserSpec: View {
    private let icon, spec: String
    
    init(_ spec: String, icon: String) {
        self.icon = icon
        self.spec = spec
    }
    
    var body: some View {
        Label(spec, systemImage: icon)
            .semibold()
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
        //            .opacity(0.95)
    }
}

#Preview {
    BrowserSpec("", icon: "hammer")
}
