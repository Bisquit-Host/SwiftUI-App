import ScrechKit

struct Browser: View {
    private var vm = BrowserVM()
    
    var body: some View {
        NavigationView {
            VStack {
                BrowserTopbar()
                    .environment(vm)
                
                ScrollView(showsIndicators: false) {
                    ForEach(vm.plans) { plan in
                        BrowserCard(plan)
                    }
                    
                    if !vm.plans.isEmpty {
                        HStack {
                            BrowserSpec("CPU", icon: "cpu")
                            
                            BrowserSpec("RAM", icon: "memorychip")
                            
                            BrowserSpec("SSD", icon: "internaldrive")
                        }
                        
                        HStack {
                            BrowserSpec("Websites", icon: "macwindow.on.rectangle")
                            
                            BrowserSpec("MySQL Databases", icon: "server.rack")
                        }
                    }
                }
            }
            .navigationTitle("Configurations")
            .toolbarTitleDisplayMode(.inline)
        }
        .task {
            await vm.fetchPlans()
        }
    }
}

#Preview {
    Browser()
}
