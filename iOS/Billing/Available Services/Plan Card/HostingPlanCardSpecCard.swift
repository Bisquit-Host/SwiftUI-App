import SwiftUI

struct HostingPlanCardSpecCard: View {
    private let icon, text: String
    private let category: BillingHostingCategory

    init(_ spec: (icon: String, text: String), in category: BillingHostingCategory) {
        self.icon = spec.icon
        self.text = spec.text
        self.category = category
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .caption2()
                .foregroundStyle(category.tint)

            Text(text)
                .caption()
                .monospacedDigit()
                .secondary()
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 8)
        .background(.fill.quaternary, in: .capsule)
    }
}
