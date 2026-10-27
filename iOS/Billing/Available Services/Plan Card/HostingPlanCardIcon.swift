import SwiftUI

struct HostingPlanCardIcon: View {
    @ScaledMetric private var size = 40

    private let category: BillingHostingCategory

    init(_ category: BillingHostingCategory) {
        self.category = category
    }

    var body: some View {
        Image(systemName: category.icon)
            .title3(.semibold)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(category.tint.gradient, in: .rect(cornerRadius: 12))
            .accessibilityHidden(true)
    }
}
