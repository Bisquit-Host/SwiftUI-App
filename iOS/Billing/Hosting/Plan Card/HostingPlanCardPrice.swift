import SwiftUI

struct HostingPlanCardPrice: View {
    @Environment(HostingPlanListVM.self) private var vm
    
    private let plan: BillingHostingPlan
    private let category: BillingHostingCategory
    
    init(_ plan: BillingHostingPlan, in category: BillingHostingCategory) {
        self.plan = plan
        self.category = category
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(vm.formattedPrice(for: plan, currency: nil))
                .monospacedDigit()
                .subheadline(.semibold)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(category.tint.opacity(0.1), in: .capsule)
                .overlay {
                    Capsule()
                        .stroke(category.tint.opacity(0.25), lineWidth: 1)
                }
            
            Text("per month")
                .caption()
                .secondary()
        }
    }
}
