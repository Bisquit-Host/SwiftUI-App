import SwiftUI

struct PanelSidebarList: View {
    @Binding var selectedTab: Tabs
    var onSelect: (Tabs) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(panelTabs) { tab in
                    PanelSidebarTabRow(tab: tab, isSelected: selectedTab == tab) {
                        onSelect(tab)
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
    
    private var panelTabs: [Tabs] {[
        .info,
        .allocations,
        .users,
        .logs,
        .subdomains,
        .console,
        .files,
        .backup,
        .schedules,
        .databases,
        .startup,
        .versionChanger,
        .modInstaller,
        .pluginInstaller,
        .modpackInstaller,
        .settings
    ]}
}

#Preview {
    @Previewable @State var tab: Tabs = .info
    
    PanelSidebarList(selectedTab: $tab) {
        tab = $0
    }
}
