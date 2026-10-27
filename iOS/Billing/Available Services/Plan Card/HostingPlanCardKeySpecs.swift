import ScrechKit

struct HostingPlanCardKeySpecs: View {
    private let plan: BillingHostingPlan
    private let category: BillingHostingCategory

    init(_ plan: BillingHostingPlan, in category: BillingHostingCategory) {
        self.plan = plan
        self.category = category
    }

    var body: some View {
        let ram = formatMegaBytes(plan.memory, countStyle: .binary)
        let disk = formatMegaBytes(plan.disk, countStyle: .binary)

        HStack(spacing: 8) {
            HostingPlanCardKeySpec("cpu", value: plan.cpu.clean, label: Text(verbatim: "vCPU"), in: category)

            HostingPlanCardKeySpec("memorychip", value: ram, label: label("RAM", type: plan.memoryType), in: category)

            HostingPlanCardKeySpec("internaldrive", value: disk, label: label("Disk", type: plan.diskType), in: category)
        }
    }

    private func label(_ title: LocalizedStringKey, type: String?) -> Text {
        guard let type, !type.isEmpty else {
            return Text(title)
        }

        return Text(verbatim: type)
    }
}
