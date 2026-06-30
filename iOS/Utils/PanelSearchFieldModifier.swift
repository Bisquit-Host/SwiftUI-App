import SwiftUI

private struct PanelSearchFieldModifier: ViewModifier {
    let showIcon: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .padding(.leading, showIcon ? 34 : 12)
            .padding(.trailing, 12)
            .background(.thinMaterial, in: .rect(cornerRadius: 12))
            .overlay(alignment: .leading) {
                if showIcon {
                    Image(systemName: "magnifyingglass")
                        .footnote(.semibold)
                        .secondary()
                        .padding(.leading, 12)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.quaternary.opacity(0.6), lineWidth: 1)
            }
    }
}

extension View {
    func panelSearchField(showIcon: Bool = true) -> some View {
        modifier(PanelSearchFieldModifier(showIcon: showIcon))
    }
}
