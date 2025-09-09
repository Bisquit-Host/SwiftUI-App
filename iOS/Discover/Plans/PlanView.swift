import ScrechKit

struct PlanView: View {
    @State private var vm = PlanListVM()
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        VStack {
            PlanListTopbar()
                .environment(vm)
            
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
        .navigationTitle("Configurations")
        .toolbarTitleDisplayMode(.inline)
        .environment(vm)
        .animation(.default, value: store.selectedPlanCategory)
        .ornamentDismissButton()
        .task {
            await vm.fetchAllPlans()
        }
    }
}

#Preview {
    NavigationStack {
        PlanView()
    }
    .environmentObject(ValueStore())
}
