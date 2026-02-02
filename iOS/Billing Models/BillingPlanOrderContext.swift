struct BillingPlanOrderContext: Identifiable, Equatable {
    let plan: BillingHostingPlan
    let category: BillingHostingCategory
    
    var id: String {
        category.rawValue + "-" + plan.id.description
    }
}
