import ScrechKit

struct PanelSidebarList: View {
    private struct SidebarSection: Identifiable {
        let title: String
        let tabs: [Tabs]
        
        var id: String { title }
    }
    
    @Binding var selectedTab: Tabs
    var onSelect: (Tabs) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(sidebarSections) { section in
                    VStack(alignment: .leading, spacing: 6) {
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
            }
            .padding(12)
        }
        .scrollIndicators(.never)
        .background(.thickMaterial)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(.quaternary)
                .frame(width: 1)
        }
    }
    
    private var sidebarSections: [SidebarSection] {[
        SidebarSection(
            title: "GENERAL",
            tabs: [
                .info,
                .console,
                .settings,
                .logs
            ]
        ),
        SidebarSection(
            title: "MANAGEMENT",
            tabs: [
                .files,
                .databases,
                .backup,
                .allocations
            ]
        ),
        SidebarSection(
            title: "MINECRAFT",
            tabs: [
                .versionChanger,
                .pluginInstaller,
                .modInstaller,
                .modpackInstaller
            ]
        ),
        SidebarSection(
            title: "CONFIGURATION",
            tabs: [
                .schedules,
                .users,
                .startup,
                .subdomains
            ]
        )
    ]}
}

#Preview {
    @Previewable @State var tab: Tabs = .info
    
    PanelSidebarList(selectedTab: $tab) {
        tab = $0
    }
}
