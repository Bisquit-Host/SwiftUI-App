import ScrechKit

struct HostingPlanCardSpecList: View {
    private let plan: BillingHostingPlan
    private let category: BillingHostingCategory

    init(_ plan: BillingHostingPlan, in category: BillingHostingCategory) {
        self.plan = plan
        self.category = category
    }

    var body: some View {
        if !specs.isEmpty {
            FlowLayout(horizontalSpacing: 6, verticalSpacing: 6) {
                ForEach(specs.enumerated(), id: \.offset) {
                    HostingPlanCardSpecCard($0.element, in: category)
                }
            }
        }
    }

    private var specs: [(icon: String, text: String)] {
        var items: [(String, String)] = []

        if let network = plan.networkDescription {
            items.append(("network", network))
        }

        if let databases = plan.databases {
            items.append(("externaldrive.fill", "\(databases) DB's"))
        }

        if let backups = plan.backups {
            items.append(("clock.arrow.circlepath", "\(backups) backups"))
        }

        if let allocations = plan.allocations {
            items.append(("number", "\(allocations) ports"))
        }

        return items
    }
}
