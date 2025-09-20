import ScrechKit

struct PlanView: View {
    @State private var vm = PlanListVM()
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        VStack {
            PlanViewTopbar()
            
            PlanViewList()
        }
        .navigationTitle("Configurations")
        .scenePadding(.horizontal)
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
