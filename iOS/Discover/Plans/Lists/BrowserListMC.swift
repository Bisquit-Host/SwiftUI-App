import SwiftUI

struct PlanListGame: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        ForEach(vm.mcPlans) {
            PlanCardGame($0)
        }
    }
}

#Preview {
    PlanListGame()
        .environment(BrowserVM())
}
