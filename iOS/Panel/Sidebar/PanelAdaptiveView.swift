import SwiftUI

struct PanelAdaptiveView<Content: View>: View {
    var showsSideBarOniPadPortrait: Bool = true
    
    @ViewBuilder var content: (CGSize, Bool) -> Content
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let isLandscape = size.width > size.height || (horizontalSizeClass == .regular && showsSideBarOniPadPortrait)
            
            content(size, isLandscape)
        }
    }
}
