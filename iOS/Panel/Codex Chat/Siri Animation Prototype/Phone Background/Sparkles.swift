import ScrechKit

struct Sparkles: View {
    private let mesh = Gradient(colors: [.yellow, .purple, .indigo])
    
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: "sparkles")
            .fontSize(40)
            .foregroundStyle(mesh)
            .breatheEffect()
    }
}

private struct BreathEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content
                .symbolEffect(.breathe)
        } else {
            content
                .symbolEffect(.pulse)
        }
    }
}

private extension View {
    func breatheEffect() -> some View {
        modifier(BreathEffectModifier())
    }
}

#Preview {
    Sparkles()
}
