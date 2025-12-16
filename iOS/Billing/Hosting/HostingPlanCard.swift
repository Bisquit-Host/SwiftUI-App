import ScrechKit

struct HostingPlanCard: View {
    @Environment(HostingPlanListVM.self) private var vm
    
    let plan: BillingHostingPlan
    let category: BillingHostingCategory
    var onPurchase: (() -> Void)?
    
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
            .buttonStyle(.glassProminent)
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
    HostingPlanCard(plan: .preview, category: .game)
        .padding()
        .darkSchemePreferred()
        .environment(HostingPlanListVM())
}
