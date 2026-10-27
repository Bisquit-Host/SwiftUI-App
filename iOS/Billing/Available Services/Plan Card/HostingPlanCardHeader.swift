import ScrechKit

struct HostingPlanCardHeader: View {
    private let plan: BillingHostingPlan
    private let category: BillingHostingCategory
    private let isAvailable: Bool

    init(_ plan: BillingHostingPlan, in category: BillingHostingCategory, isAvailable: Bool) {
        self.plan = plan
        self.category = category
        self.isAvailable = isAvailable
    }

    var body: some View {
        HStack(spacing: 12) {
            HostingPlanCardIcon(category)
                .saturation(isAvailable ? 1 : 0)
                .opacity(isAvailable ? 1 : 0.5)

            VStack(alignment: .leading, spacing: 2) {
                Text(plan.name)
                    .headline()
                    .foregroundStyle(isAvailable ? .primary : .secondary)
                    .lineLimit(2)

                if let cpuName = plan.cpuName, !cpuName.isEmpty {
                    Text(cpuName)
                        .caption()
                        .secondary()
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            if !isAvailable {
                HostingPlanCardSoldOutBadge()
            }
        }
    }
}
