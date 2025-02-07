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
#if !os(tvOS)
        .scrollContentBackground(store.transparentSheet ? .hidden : .visible)
        .presentationBackground(store.transparentSheet ? .ultraThinMaterial : .regular)
#endif
        .task {
            await vm.fetchPlans()
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
