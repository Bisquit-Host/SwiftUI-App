import SwiftUI

struct PlanListGame: View {
    @Environment(PlanListVM.self) private var vm
    
    var body: some View {
        ForEach(vm.mcPlans) {
            PlanCardGame($0)
        }
    }
}

#Preview {
    PlanListGame()
        .environment(PlanListVM())
}
