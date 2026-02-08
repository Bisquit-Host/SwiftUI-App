import ScrechKit

struct PanelSidebarCustomizationSheet: View {
    @Environment(PanelSidebarCustomizationVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(PanelSidebarSection.all) { section in
                Section(section.title) {
                    ForEach(section.tabs) {
                        PanelSidebarCustomizationTabToggle(tab: $0)
                    }
                }
            }
        }
        .navigationTitle("Customization")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reset", action: vm.reset)
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
