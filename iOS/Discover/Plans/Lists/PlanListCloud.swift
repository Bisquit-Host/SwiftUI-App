import SwiftUI

struct PlanListCloud: View {
    @Environment(PlanListVM.self) private var vm
    
    var body: some View {
        ForEach(vm.vdsPlans) {
            PlanCardCloud($0)
        }
    }
}

#Preview {
    PlanListCloud()
        .environment(PlanListVM())
}
