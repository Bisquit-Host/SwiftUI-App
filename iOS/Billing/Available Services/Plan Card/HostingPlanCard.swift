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

        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                HostingPlanCardIcon(category)
                    .saturation(isAvailable ? 1 : 0)
                    .opacity(isAvailable ? 1 : 0.5)

                Text(plan.name)
                    .headline()
                    .foregroundStyle(isAvailable ? .primary : .secondary)

                Spacer()

                HostingPlanCardPrice(plan, in: category, onPurchase: onPurchase)
            }

            Divider()
                .overlay(category.tint.opacity(isAvailable ? 0.15 : 0))

            HostingPlanCardSpecList(plan, in: category)
                .saturation(isAvailable ? 1 : 0)
                .opacity(isAvailable ? 1 : 0.5)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.primary.opacity(isAvailable ? 0.08 : 0.04), lineWidth: 1)
        }
        .shadow(color: category.tint.opacity(isAvailable ? 0.05 : 0), radius: 12, y: 6)
    }
}

#Preview {
    HostingPlanCard(.preview, in: .game)
        .padding()
        .darkSchemePreferred()
        .environment(HostingPlanListVM())
}
