import SwiftUI

struct PlanListWeb: View {
    @Environment(PlanListVM.self) private var vm
    
    var body: some View {
        ForEach(vm.webPlans) {
            PlanCardWeb($0)
        }
    }
}

#Preview {
    PlanListWeb()
        .environment(PlanListVM())
}
