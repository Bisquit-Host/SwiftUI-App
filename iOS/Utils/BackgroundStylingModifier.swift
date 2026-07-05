import SwiftUI

private struct BackgroundStylingModifier<S: Shape>: ViewModifier {
    let shape: S
    
    @ViewBuilder
    func body(content: Content) -> some View {
#if os(visionOS)
        content
            .background(.ultraThinMaterial, in: shape)
#else
        content
            .glassEffect(in: shape)
#endif
    }
}

extension View {
    func backgroundStyling<S: Shape>(_: PanelSidebarBackgroundStyle = .glass, in shape: S) -> some View {
        modifier(BackgroundStylingModifier(shape: shape))
    }
}
