import ScrechKit

struct PanelSidebarCustomizationSheet: View {
    @Environment(PanelSidebarCustomizationVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(PanelSidebarSection.all) { section in
                Section(section.title) {
                    ForEach(section.tabs) { tab in
                        PanelSidebarCustomizationTabToggle(tab: tab)
                    }
                }
            }
        }
        .navigationTitle("Customization")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reset") {
                    vm.reset()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PanelSidebarCustomizationSheet()
            .environment(PanelSidebarCustomizationVM())
    }
    .darkSchemePreferred()
}
