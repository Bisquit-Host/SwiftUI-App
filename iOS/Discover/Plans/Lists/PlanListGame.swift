import SwiftUI

struct PlanListGame: View {
    @Environment(PlanListVM.self) private var vm
    
    var body: some View {
        ForEach(vm.gamePlans) {
            PlanCardGame($0)
        }
    }
}

#Preview {
    PlanListGame()
        .environment(PlanListVM())
}
