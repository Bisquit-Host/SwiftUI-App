import SwiftUI

#if os(iOS)
@available(iOS 27.1, *)
struct ToolbarScenePaddingModifier: ViewModifier {
    @Environment(\.toolbarVerticalEdge) private var verticalEdge

    func body(content: Content) -> some View {
        content
            .scenePadding(verticalEdge == .trailing ? .leading : .horizontal)
    }
}
#endif

extension View {
    @ViewBuilder
    func toolbarScenePadding() -> some View {
        #if os(iOS)
        if #available(iOS 27.1, *) {
            modifier(ToolbarScenePaddingModifier())
        } else {
            scenePadding(.horizontal)
        }
        #else
        scenePadding(.horizontal)
        #endif
    }
}
