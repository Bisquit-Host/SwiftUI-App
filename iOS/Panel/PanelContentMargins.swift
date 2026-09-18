import SwiftUI

struct PanelContentMargins: ViewModifier {
    @Environment(\.panelHasPersistentSidebar) private var hasPersistentSidebar

    func body(content: Content) -> some View {
        content
            .safeAreaPadding(.horizontal, hasPersistentSidebar ? nil : 0)
    }
}

extension View {
    func panelContentMargins() -> some View {
        modifier(PanelContentMargins())
    }
}
