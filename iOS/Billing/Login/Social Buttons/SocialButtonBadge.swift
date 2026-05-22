import ScrechKit

struct SocialButtonBadge: View {
    private let title: LocalizedStringKey
    
    init(_ title: LocalizedStringKey) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .caption2(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
#if !os(visionOS)
            .glassEffect()
#endif
            .offset(y: 14)
    }
}

#Preview {
    SocialButtonBadge("Preview")
}
