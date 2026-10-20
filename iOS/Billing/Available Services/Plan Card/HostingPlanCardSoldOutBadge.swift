import SwiftUI

struct HostingPlanCardSoldOutBadge: View {
    var body: some View {
        Text("Sold out")
            .subheadline(.semibold)
            .secondary()
            .padding(.vertical, 7)
            .padding(.horizontal, 14)
            .background(.fill.tertiary, in: .capsule)
            .overlay {
                Capsule()
                    .stroke(.primary.opacity(0.08), lineWidth: 1)
            }
            .accessibilityLabel("Out of stock")
    }
}

#Preview {
    HostingPlanCardSoldOutBadge()
        .padding()
        .darkSchemePreferred()
}
