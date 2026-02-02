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
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                HostingPlanCardIcon(category)
                
                Text(plan.name)
                    .headline()
                
                Spacer()
                
                HostingPlanCardPrice(plan, in: category)
            }
            
            Divider()
                .overlay(category.tint.opacity(0.15))
            
            HostingPlanCardSpecList(plan, in: category)
            
            SFButton("cart.badge.plus") {
                onPurchase?()
            }
#if !os(visionOS)
            .buttonStyle(.glassProminent)
#endif
            .tint(category.tint)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: category.tint.opacity(0.05), radius: 12, y: 6)
    }
}

#Preview {
    HostingPlanCard(.preview, in: .game)
        .padding()
        .darkSchemePreferred()
        .environment(HostingPlanListVM())
}
