import SwiftUI

@available(iOS 27.1, visionOS 27.1, *)
struct ToolbarScenePaddingModifier: ViewModifier {
    @Environment(\.toolbarVerticalEdge) private var verticalEdge

    func body(content: Content) -> some View {
        content
            .scenePadding(verticalEdge == .trailing ? .leading : .horizontal)
    }
}

extension View {
    @ViewBuilder
    func toolbarScenePadding() -> some View {
        if #available(iOS 27.1, visionOS 27.1, *) {
            modifier(ToolbarScenePaddingModifier())
        } else {
            scenePadding(.horizontal)
        }
    }
}
