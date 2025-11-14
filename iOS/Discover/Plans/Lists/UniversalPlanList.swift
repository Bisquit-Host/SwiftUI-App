import SwiftUI

struct UniversalPlanList: View {
    private let plans: [UniversalPlan]
    
    init(_ plans: [UniversalPlan]) {
        self.plans = plans
    }
    
    var body: some View {
        ForEach(plans) {
            PlanCard($0)
        }
    }
}

#Preview {
    UniversalPlanList([])
        .darkSchemePreferred()
        .environment(PlanListVM())
}
