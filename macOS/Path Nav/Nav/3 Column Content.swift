// A grid of recipe tiles, based on a given recipe category

import SwiftUI

struct ThreeColumnContent: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        @Bindable var nav = nav
        
        VStack {
            if nav.selectedServer.isEmpty {
                ContentUnavailableView("Choose a server", systemImage: "server.rack")
            } else {
                List(selection: $nav.selectedTab) {
                    ForEach(Tabs.allCases) { tab in
                        NavigationLink(tab.title, value: tab)
                    }
                }
                .scrollContentBackground(.hidden)
                .onDisappear {
                    nav.selectedTab = nil
                }
            }
        }
        .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview() {
    ThreeColumnContent()
        .environment(ServerListVM())
        .environment(NavModel(selectedCategory: nil))
}
