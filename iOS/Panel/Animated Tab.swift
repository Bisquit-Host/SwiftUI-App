import SwiftUI

struct AnimatedTab: Identifiable {
    var id: UUID = .init()
    var tab: Tabs
    var isAnimating: Bool?
}

#if !os(watchOS) && !os(macOS)
extension View {
    @ViewBuilder
    func setUpTab(_ tab: Tabs, isAnimated: Bool) -> some View {
        if isAnimated {
            self
                .tag(tab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar(.hidden, for: .tabBar)
        } else {
            self
                .tag(tab)
                .tabItem {
                    Label(tab.title, systemImage: tab.rawValue)
                }
        }
    }
}
#endif
