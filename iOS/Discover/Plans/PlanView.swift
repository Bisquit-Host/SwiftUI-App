import ScrechKit

struct PlanView: View {
    @State private var vm = PlanListVM()
    
    var body: some View {
        VStack {
            PlanListTopbar()
                .environment(vm)
            
            ScrollView(showsIndicators: false) {
                switch vm.selectedCategory {
                case .game:
                    PlanListGame()
                    
                case .cloud:
                    PlanListCloud()
                    
                case .web:
                    PlanListWeb()
                    
                case .bot:
                    PlanListBot()
                }
                
                HStack {
                    PlanSpec("CPU", icon: "cpu")
                    PlanSpec("RAM", icon: "memorychip")
                    PlanSpec("SSD", icon: "internaldrive")
                }
                
                HStack {
                    PlanSpec("Websites", icon: "macwindow.on.rectangle")
                    PlanSpec("MySQL Databases", icon: "server.rack")
                }
            }
        }
        .navigationTitle("Configurations")
        .toolbarTitleDisplayMode(.inline)
        .environment(vm)
        .animation(.default, value: vm.selectedCategory)
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
