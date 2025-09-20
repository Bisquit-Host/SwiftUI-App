import SwiftUI

struct PlanViewList: View {
    @Environment(PlanListVM.self) private var vm: PlanListVM
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            switch store.selectedPlanCategory {
            case .game:
                PlanListGame()
                
            case .cloud:
                UniversalPlanList(vm.cloudPlans)
                
            case .web:
                UniversalPlanList(vm.webPlans)
                
            case .bot:
                UniversalPlanList(vm.botPlans)
            }
        }
    }
}

#Preview {
    PlanViewList()
        .environment(PlanListVM())
        .environmentObject(ValueStore())
}
