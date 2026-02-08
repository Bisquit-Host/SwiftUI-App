import SwiftUI

private struct BackgroundStylingModifier<S: Shape>: ViewModifier {
    let style: PanelSidebarBackgroundStyle
    let shape: S
    
    @ViewBuilder
    func body(content: Content) -> some View {
        switch style {
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
    func backgroundStyling<S: Shape>(_ style: PanelSidebarBackgroundStyle = .ultraThinMaterial, in shape: S) -> some View {
        modifier(BackgroundStylingModifier(style: style, shape: shape))
    }
}
