import SwiftUI

struct PanelSidebarList: View {
    @Binding var selectedTab: Tabs
    var onSelect: (() -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(panelTabs) { tab in
                    PanelSidebarTabRow(tab: tab, isSelected: selectedTab == tab) {
                        selectedTab = tab
                        onSelect?()
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
    
    private var panelTabs: [Tabs] {
        [.info, .console, .files, .backup, .startup]
    }
}

#Preview {
    @Previewable @State var tab: Tabs = .info
    
    PanelSidebarList(selectedTab: $tab)
}
