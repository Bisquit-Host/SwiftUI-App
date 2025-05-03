// A grid of recipe tiles, based on a given recipe category

import SwiftUI

struct SectionList: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        @Bindable var nav = nav
        
        if nav.selectedServer.isEmpty {
            ContentUnavailableView("Choose a server", systemImage: "server.rack")
        } else {
            List(selection: $nav.selectedTab) {
                ForEach(Tabs.allCases) { tab in
                    NavigationLink(tab.title, value: Route.tab(tab))
                }
            }
            .scrollContentBackground(.hidden)
            .backgroundBlur()
            .frame(minWidth: 300)
            .onDisappear {
                nav.selectedTab = nil
            }
        }
    }
}

//#Preview() {
//    PanelSectionList()
//        .environment(ServerListVM())
//        .environment(NavModel(selectedCategory: .dessert))
//}

#Preview() {
    SectionList()
        .environment(ServerListVM())
        .environment(NavModel(selectedCategory: nil))
}
