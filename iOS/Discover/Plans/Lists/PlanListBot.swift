import SwiftUI

struct PlanListBot: View {
    @Environment(PlanListVM.self) private var vm
    
    var body: some View {
        ForEach(vm.botPlans) {
            PlanCard($0)
        }
    }
}

#Preview {
    PlanListBot()
        .environment(PlanListVM())
}
