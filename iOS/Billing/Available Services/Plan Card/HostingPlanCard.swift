import ScrechKit

struct HostingPlanCard: View {
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
        let isAvailable = vm.isAvailable(plan, in: category)

        VStack(alignment: .leading, spacing: 16) {
            HostingPlanCardHeader(plan, in: category, isAvailable: isAvailable)

            VStack(alignment: .leading, spacing: 10) {
                HostingPlanCardKeySpecs(plan, in: category)

                HostingPlanCardSpecList(plan, in: category)
            }
            .saturation(isAvailable ? 1 : 0)
            .opacity(isAvailable ? 1 : 0.6)

            Spacer(minLength: 0)

            HostingPlanCardPrice(plan, in: category, onPurchase: onPurchase)
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            HostingPlanCardBackground(category, isAvailable: isAvailable)
        }
        .clipShape(.rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.primary.opacity(isAvailable ? 0.08 : 0.04), lineWidth: 1)
        }
        .shadow(color: category.tint.opacity(isAvailable ? 0.08 : 0), radius: 16, y: 8)
    }
}

#Preview {
    HostingPlanCard(.preview, in: .game)
        .padding()
        .darkSchemePreferred()
        .environment(HostingPlanListVM())
}
