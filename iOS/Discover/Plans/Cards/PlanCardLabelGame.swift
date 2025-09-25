import SwiftUI

struct PlanCardLabelGame: View {
    private let plan: UniversalPlan
    
    init(_ plan: UniversalPlan) {
        self.plan = plan
    }
    
    var body: some View {
        HStack {
            if let cpu = plan.cpu {
                PlanSpec("CPU", icon: "cpu", value: "\(customRound(cpu))x")
            }
            
            if let ram = plan.memoryGB {
                PlanSpec("RAM", icon: "memorychip", value: "\(customRound(ram)) GB")
            }
            
            PlanSpec("Storage", icon: "internaldrive", value: "\(plan.diskGB) GB")
        }
    }
}

//#Preview {
//    PlanCardLabelGame()
//    .darkSchemePreferred()
//}
