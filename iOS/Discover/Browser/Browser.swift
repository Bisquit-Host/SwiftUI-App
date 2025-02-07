import ScrechKit

struct Browser: View {
    @State private var vm = BrowserVM()
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            BrowserTopbar()
                .environment(vm)
            
            ScrollView(showsIndicators: false) {
                switch vm.selectedCategory {
                case .mc:
                    Text("Minecraft \(vm.mcPlans.count)")
                    
                case .vds:
                    Text("VDS \(vm.vdsPlans.count)")
                    
                case .web:
                    Text("Web \(vm.webPlans.count)")
                    
                case .bot:
                    Text("Bot \(vm.botPlans.count)")
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
#if !os(tvOS)
        .scrollContentBackground(store.transparentSheet ? .hidden : .visible)
        .presentationBackground(store.transparentSheet ? .ultraThinMaterial : .regular)
#endif
        .refreshableTask {
            await vm.fetchAllPlans()
        }
#if os(visionOS)
        .ornament(attachmentAnchor: .scene(.bottom)) {
            Button("Dismiss") {
                dismiss()
            }
        }
#endif
    }
}

#Preview {
    Browser()
        .environmentObject(ValueStore())
}
