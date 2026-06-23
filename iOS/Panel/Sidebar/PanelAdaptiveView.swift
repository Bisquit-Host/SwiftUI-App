import SwiftUI

struct PanelAdaptiveView<Content: View>: View {
    var showsSideBarOniPadPortrait: Bool = true
    
    @ViewBuilder var content: (CGSize, Bool) -> Content
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let isLandscape =
                if horizontalSizeClass == .compact {
                    verticalSizeClass == .compact
                } else {
                    horizontalSizeClass == .regular && (showsSideBarOniPadPortrait || verticalSizeClass == .compact)
                }
            
            content(size, isLandscape)
        }
    }
}
