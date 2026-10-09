import SwiftUI

// Scrolling the sidebar must never minimize the navigation bar of the selected tab
struct PanelSidebarBarMinimization: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 27, *) {
            content
                .toolbarMinimizationBehavior(.never, for: .navigationBar)
        } else {
            content
        }
    }
}

extension View {
    func panelSidebarBarMinimizationDisabled() -> some View {
        modifier(PanelSidebarBarMinimization())
    }
}
