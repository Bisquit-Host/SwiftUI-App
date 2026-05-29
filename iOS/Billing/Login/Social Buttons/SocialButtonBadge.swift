import ScrechKit

struct SocialButtonBadge: View {
    var body: some View {
        Image(systemName: "star.fill")
            .font(.caption.bold())
            .foregroundStyle(.yellow)
            .frame(24)
#if !os(visionOS)
            .glassEffect()
#endif
            .clipShape(.circle)
            .offset(x: 6, y: -5)
            .accessibilityLabel("Last used")
    }
}

#Preview {
    SocialButtonBadge()
}
