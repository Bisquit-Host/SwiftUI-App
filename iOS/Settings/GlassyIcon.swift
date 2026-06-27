import SwiftUI

struct GlassyIcon: View {
    private let icon: String
    private let tint: Color
    private let size: CGFloat
    
    init(_ icon: String, tint: Color, size: CGFloat = 32) {
        self.icon = icon
        self.tint = tint
        self.size = size
    }
    
    var body: some View {
        Image(systemName: icon)
            .frame(size)
            .foregroundStyle(tint)
#if !os(visionOS)
            .glassEffect(.regular.tint(tint.opacity(0.15)), in: .rect(cornerRadius: max(10, size * 0.25)))
#endif
    }
}

#Preview {
    GlassyIcon("hammer", tint: .blue)
        .darkSchemePreferred()
}
