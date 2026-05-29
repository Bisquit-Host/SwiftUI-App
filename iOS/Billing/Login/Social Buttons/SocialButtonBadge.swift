import SwiftUI

struct SocialButtonBadge: View {
    var body: some View {
        Image(systemName: "star.fill")
            .font(.caption.bold())
            .foregroundStyle(.yellow)
            .frame(width: 24, height: 24)
#if !os(visionOS)
            .glassEffect()
#endif
            .clipShape(.circle)
            .offset(x: 7, y: -7)
            .accessibilityLabel("Last used")
    }
}

#Preview {
    SocialButtonBadge()
}
