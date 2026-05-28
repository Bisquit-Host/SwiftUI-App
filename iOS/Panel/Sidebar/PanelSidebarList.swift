import ScrechKit

struct PanelSidebarList: View {
    @Environment(PanelSidebarCustomizationVM.self) private var customizationVM
    @Environment(PanelVM.self) private var panelVM
    
    @Binding var selectedTab: Tabs
    var onSelect: (Tabs) -> Void
    var onCustomize: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PanelSidebarHeader(server: panelVM.server)
                
                PanelSidebarPowerControls()
                
                ForEach(customizationVM.visibleSections) { section in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(section.title)
                            .caption(.semibold)
                            .secondary()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 2)
                        
                        ForEach(section.tabs) { tab in
                            PanelSidebarTabRow(tab: tab, isSelected: selectedTab == tab) {
                                onSelect(tab)
                            }
                        }
                    }
                }
                
                PanelSidebarCustomizationButton(action: onCustomize)
                    .padding(.top, 14)
            }
            .padding(12)
        }
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    @Previewable @State var tab: Tabs = .info
    
    PanelSidebarList(selectedTab: $tab) {
        tab = $0
    } onCustomize: {
        
    }
    .environment(PanelSidebarCustomizationVM())
}
