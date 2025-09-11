import SwiftUI

struct PlanCardLabelWeb: View {
    private let plan: UniversalPlan
    
    init(_ plan: UniversalPlan) {
        self.plan = plan
    }
    
    var body: some View {
        HStack {
            PlanSpec("Storage", icon: "internaldrive", value: "\(plan.diskGB) GB")
            
            if let databases = plan.databases {
                PlanSpec("DB's", icon: "server.rack", value: "\(databases)x")
            }
        }
    }
}

//#Preview {
//    PlanCardLabelWeb()
//}
