import SwiftUI

struct HostingPlanCardPrice: View {
    @Environment(HostingPlanListVM.self) private var vm

    private let plan: BillingHostingPlan
    private let category: BillingHostingCategory
    private let onPurchase: (() -> Void)?

    init(_ plan: BillingHostingPlan, in category: BillingHostingCategory, onPurchase: (() -> Void)? = {}) {
        self.plan = plan
        self.category = category
        self.onPurchase = onPurchase
    }

    var body: some View {
        let price = vm.formattedPrice(for: plan, currency: nil)
        let isAvailable = vm.isAvailable(plan, in: category)

        VStack(alignment: isAvailable ? .center : .trailing, spacing: 2) {
            if isAvailable {
                Button {
                    onPurchase?()
                } label: {
                    Text(price)
                        .monospacedDigit()
                        .subheadline(.semibold)
                }
#if !os(visionOS)
                .buttonStyle(.glassProminent)
#endif
                .tint(category.tint.opacity(0.9))

                Text("per month")
                    .caption()
                    .secondary()
            } else {
                HostingPlanCardSoldOutBadge()

                Text("\(price) per month")
                    .caption()
                    .monospacedDigit()
                    .secondary()
            }
        }
    }
}
