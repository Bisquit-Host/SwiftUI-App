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
        VStack(spacing: 2) {
            Button {
                onPurchase?()
            } label: {
                Text(vm.formattedPrice(for: plan, currency: nil))
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
        }
    }
}
