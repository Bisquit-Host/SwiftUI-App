// A grid of server tiles, based on a given server category

import SwiftUI

struct ThreeColumnContent: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        @Bindable var nav = nav
        
        VStack {
            if nav.selectedServers.isEmpty {
                ContentUnavailableView("Choose a server", systemImage: "server.rack")
            } else {
                List(selection: $nav.selectedTab) {
                    ForEach(nav.enabledTabs) { tab in
                        NavigationLink(tab.name, value: tab)
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

#Preview {
    ThreeColumnContent()
        .environment(NavModel(selectedCategory: nil))
}
