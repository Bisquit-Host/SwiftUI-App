import SwiftUI

struct PanelSidebarDrawer: View {
    @Binding var selectedTab: Tabs
    
    let width: Double
    let offset: Double
    let progress: Double
    let onSelect: (Tabs) -> Void
    let onClose: () -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            Button(action: onClose) {
                Rectangle()
                    .fill(.black.opacity(0.25))
                    .ignoresSafeArea()
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close sidebar")
            .opacity(progress)
            .allowsHitTesting(progress > 0)
            .accessibilityHidden(progress == 0)
            
            PanelSidebarPane(selectedTab: $selectedTab, width: width, onSelect: onSelect)
                .offset(x: offset - width)
                .allowsHitTesting(progress > 0)
                .accessibilityHidden(progress == 0)
        }
    }
}
