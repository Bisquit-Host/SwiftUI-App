import SwiftUI

private struct BackgroundStylingModifier<S: Shape>: ViewModifier {
    let style: PanelSidebarBackgroundStyle
    let shape: S
    
    @ViewBuilder
    func body(content: Content) -> some View {
        switch style {
        case .glass:
#if os(visionOS)
            content
                .background(.ultraThinMaterial, in: shape)
#else
            content
                .glassEffect(in: shape)
#endif
        case .ultraThinMaterial:
            content
                .background(.ultraThinMaterial, in: shape)
            
        case .ultraThickMaterial:
            content
                .background(.ultraThickMaterial, in: shape)
        }
    }
}

extension View {
    func backgroundStyling<S: Shape>(_ style: PanelSidebarBackgroundStyle = .glass, in shape: S) -> some View {
        modifier(BackgroundStylingModifier(style: style, shape: shape))
    }
}
