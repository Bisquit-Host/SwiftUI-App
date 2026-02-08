import ScrechKit

struct PanelSidebarCustomizationSheet: View {
    @Environment(PanelSidebarCustomizationVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section("SIDEBAR") {
                Picker("Position", selection: $vm.placement) {
                    ForEach(PanelSidebarPlacement.allCases, id: \.self) { placement in
                        Label(placement.title, systemImage: placement.icon)
                            .tag(placement)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("Version section background", selection: $vm.backgroundStyle) {
                    ForEach(PanelSidebarBackgroundStyle.selectableCases) { style in
                        Text(style.title)
                            .tag(style)
                    }
                }
                .pickerStyle(.menu)
            }
            
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
