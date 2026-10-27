import ScrechKit

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

        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text(price)
                    .title2(.bold)
                    .monospacedDigit()
                    .foregroundStyle(isAvailable ? .primary : .secondary)
                    .contentTransition(.numericText())

                Text("per month")
                    .caption()
                    .secondary()
            }

            Spacer(minLength: 0)

            if isAvailable {
                Button("Purchase", systemImage: "cart.fill") {
                    onPurchase?()
                }
                .subheadline(.semibold)
#if !os(visionOS)
                .buttonStyle(.glassProminent)
#else
                .buttonStyle(.borderedProminent)
#endif
                .tint(category.tint)
            }
        }
    }
}
