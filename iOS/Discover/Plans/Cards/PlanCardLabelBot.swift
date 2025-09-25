import SwiftUI

struct PlanCardLabelBot: View {
    private let plan: UniversalPlan
    
    init(_ plan: UniversalPlan) {
        self.plan = plan
    }
    
    var body: some View {
        HStack {
            if let ram = plan.memoryGB {
                PlanSpec("RAM", icon: "memorychip", value: "\(customRound(ram)) GB")
            }
            
            if let cpu = plan.cpu {
                PlanSpec("CPU", icon: "cpu", value: "\(customRound(cpu))x")
            }
            
            PlanSpec("Storage", icon: "internaldrive", value: "\(plan.diskGB) GB")
        }
    }
}

//#Preview {
//    PlanCardLabelBot()
//    .darkSchemePreferred()
//}
