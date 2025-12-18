import SwiftUI

struct GlassyIcon: View {
    private let icon: String
    private let tint: Color
    
    init(_ icon: String, tint: Color) {
        self.icon = icon
        self.tint = tint
    }
    
    var body: some View {
        Image(systemName: icon)
            .frame(32)
            .glassEffect(.regular.tint(tint.opacity(0.15)), in: .rect(cornerRadius: 10))
            .foregroundStyle(tint)
    }
}

#Preview {
    GlassyIcon("hammer", tint: .blue)
        .darkSchemePreferred()
}
