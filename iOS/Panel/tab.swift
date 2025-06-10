import SwiftUI

extension View {
    func tab(_ tab: Tabs) -> some View {
        self
            .tag(tab)
            .tabItem {
                Label(tab.title, systemImage: tab.rawValue)
            }
    }
}
