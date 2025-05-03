// A grid of recipe tiles, based on a given recipe category

import ScrechKit
import PteroNet

struct RecipeGrid: View {
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
//            .onDisappear {
//                nav.selectedTab = nil
//            }
            .toolbar {
                SFButton("pencil") {
                    //                        sheetCustomization = true
                }
            }
        }
    }
}

//#Preview() {
//    RecipeGrid()
//        .environment(DataModel())
//        .environment(NavModel(selectedCategory: .dessert))
//}

#Preview() {
    RecipeGrid()
        .environment(DataModel())
        .environment(NavModel(selectedCategory: nil))
}
