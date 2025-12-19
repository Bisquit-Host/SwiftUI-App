import ScrechKit

struct HostingPlanCardSpecList: View {
    private let plan: BillingHostingPlan
    private let category: BillingHostingCategory
    
    init(_ plan: BillingHostingPlan, in category: BillingHostingCategory) {
        self.plan = plan
        self.category = category
    }
    
    var body: some View {
        FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
            ForEach(Array(specs.enumerated()), id: \.offset) { _, item in
                HostingPlanCardSpecCard(item, in: category)
            }
        }
    }
    
    private var specs: [(icon: String, text: String)] {
        let ram = formatMegaBytes(plan.memory)
        let disk = formatMegaBytes(plan.disk)
        
        var items: [(String, String)] = [
            ("cpu", "\(plan.cpu.clean) vCPU"),
            ("memorychip", "\(ram) RAM"),
            ("internaldrive", "\(disk) \(plan.diskType ?? "")".trimmingCharacters(in: .whitespaces))
        ]
        
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
