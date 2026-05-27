import ScrechKit

struct PanelSidebarCustomizationSheet: View {
    @Environment(PanelSidebarCustomizationVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section("Sidebar") {
                Picker("Position", selection: $vm.placement) {
                    ForEach(PanelSidebarPlacement.allCases, id: \.self) {
                        Label($0.title, systemImage: $0.icon)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                
                VStack(alignment: .leading) {
                    Text("Section background")
                    
                    Picker(selection: $vm.backgroundStyle) {
                        ForEach(PanelSidebarBackgroundStyle.selectableCases) {
                            Text($0.title)
                                .tag($0)
                        }
                    } label: {
                        
                    }
                    .pickerStyle(.menu)
                    .tint(.secondary)
                }
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
        .scrollIndicators(.never)
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
