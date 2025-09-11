import SwiftUI

struct UniversalPlanList: View {
    @Environment(PlanListVM.self) private var vm
    
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
        .environment(PlanListVM())
}
