import SwiftUI

struct PanelToolbarItem<Content: View>: ToolbarContent {
    @Environment(\.panelToolbarButtonsVisible) private var buttonsVisible

    private let placement: ToolbarItemPlacement
    private let content: Content

    init(
        placement: ToolbarItemPlacement = .automatic,
        @ViewBuilder content: () -> Content
    ) {
        self.placement = placement
        self.content = content()
    }

    var body: some ToolbarContent {
        if buttonsVisible {
            ToolbarItem(placement: placement) {
                content
                    .transition(.opacity)
            }
        }
    }
}
