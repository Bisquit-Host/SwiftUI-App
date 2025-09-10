import SwiftUI

struct PlanViewList: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            switch store.selectedPlanCategory {
            case .game:
                PlanListGame()
                
            case .cloud:
                PlanListCloud()
                
            case .web:
                PlanListWeb()
                
            case .bot:
                PlanListBot()
            }
        }
    }
}

#Preview {
    PlanViewList()
        .environmentObject(ValueStore())
}
