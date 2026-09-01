import SwiftUI

struct PanelNavigationTitleModifier: ViewModifier {
    @Environment(\.panelUsesSharedNavigationTitle) private var usesSharedNavigationTitle
    
    let title: LocalizedStringKey
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if usesSharedNavigationTitle {
            content
        } else {
            content.navigationTitle(title)
        }
    }
}

extension View {
    func panelNavigationTitle(_ title: LocalizedStringKey) -> some View {
        modifier(PanelNavigationTitleModifier(title: title))
    }
}
