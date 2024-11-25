import SwiftUI

struct AnimatedTab: Identifiable {
    var id: UUID = .init()
    var tab: Tabs
    var isAnimating: Bool?
}

#if !os(watchOS) && !os(macOS)
extension View {
    @ViewBuilder
    func tab(_ tab: Tabs) -> some View {
        self
            .tag(tab)
            .tabItem {
                Label(tab.title, systemImage: tab.rawValue)
            }
    }
}
#endif
