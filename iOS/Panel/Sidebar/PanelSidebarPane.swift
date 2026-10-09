import SwiftUI

struct PanelSidebarPane: View {
    @Binding var selectedTab: Tabs
    
    let width: Double
    let onSelect: (Tabs) -> Void
    
    var body: some View {
        PanelSidebarList(selectedTab: $selectedTab, onSelect: onSelect)
            .frame(width: width)
            .frame(maxHeight: .infinity)
            .background(.thickMaterial)
    }
}
