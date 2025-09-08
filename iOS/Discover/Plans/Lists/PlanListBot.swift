import SwiftUI

struct PlanListBot: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        ForEach(vm.botPlans) {
            PlanCardBot($0)
        }
    }
}

#Preview {
    PlanListBot()
        .environment(BrowserVM())
}
