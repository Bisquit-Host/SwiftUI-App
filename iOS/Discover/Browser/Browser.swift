import ScrechKit

struct Browser: View {
    @State private var vm = BrowserVM()
    
    @Environment(\.dismiss) private var dismiss
    
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
        .environment(vm)
        .navigationTitle("Configurations")
        .animation(.default, value: vm.selectedCategory)
        .toolbarTitleDisplayMode(.inline)
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
