import ScrechKit

struct Browser: View {
    @State private var vm = BrowserVM()
    
    var body: some View {
        VStack {
            BrowserTopbar()
                .environment(vm)
            
            ScrollView(showsIndicators: false) {
                switch vm.selectedCategory {
                case .mc:
                    BrowserListMC()
                    
                case .mcru:
                    BrowserListMCRU()
                    
                case .vds:
                    BrowserListVds()
                    
                case .web:
                    BrowserListWeb()
                    
                case .bot:
                    BrowserListBot()
                }
                
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
    Browser()
        .environmentObject(ValueStore())
}
