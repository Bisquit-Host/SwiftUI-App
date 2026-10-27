import SwiftUI

struct HostingPlanCardBackground: View {
    private let category: BillingHostingCategory
    private let isAvailable: Bool

    init(_ category: BillingHostingCategory, isAvailable: Bool) {
        self.category = category
        self.isAvailable = isAvailable
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            LinearGradient(
                colors: [category.tint.opacity(isAvailable ? 0.18 : 0.05), .clear],
                startPoint: .topLeading,
                endPoint: .center
            )
        }
    }
}
