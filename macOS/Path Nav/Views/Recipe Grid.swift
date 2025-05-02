// A grid of recipe tiles, based on a given recipe category

import ScrechKit
import PteroNet

struct RecipeGrid: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let columns = [
        GridItem(.adaptive(minimum: 240))
    ]
    
    var body: some View {
        @Bindable var nav = nav
        
        VStack {
            if !nav.selectedServer.isEmpty {
                List(selection: $nav.selectedTab) {
                    ForEach(Tabs.allCases) { tab in
                        NavigationLink(tab.title, value: tab)
                    }
                }
                .navigationTitle(nav.selectedServer.first?.name ?? "Multiple servers selected")
                .onDisappear {
                    nav.selectedTab = nil
                }
                .toolbar {
                    SFButton("pencil") {
//                        sheetCustomization = true
                    }
                }
            } else {
                Text("Choose a server")
                    .navigationTitle("")
            }
        }
        .navigationDestination(for: Tabs.self) { tab in
            Text("Tab: \(tab.title)")
        }
    }
}

//#Preview() {
//    RecipeGrid()
//        .environment(DataModel.shared)
//        .environment(NavModel(selectedCategory: .dessert))
//}

#Preview() {
    RecipeGrid()
        .environment(DataModel.shared)
        .environment(NavModel(selectedCategory: nil))
}
