import ScrechKit

struct Browser: View {
    private var vm = BrowserVM()
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        NavigationView {
            VStack {
                BrowserTopbar()
                    .environment(vm)
                
                ScrollView(showsIndicators: false) {
                    ForEach(vm.filteredPlans, id: \.self) { plan in
                        BrowserCard(plan)
                    }
#if !os(tvOS)
                    BrowserHints()
#endif
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
        .environmentObject(SettingsStorage())
}
