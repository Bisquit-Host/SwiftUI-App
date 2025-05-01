// The content view for the two-column navigation split view experience

import SwiftUI

struct TwoColumnContentView: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = Category.allCases
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            List(categories, selection: $nav.selectedCategory) { category in
                NavigationLink(category.localizedName, value: category)
            }
            .navigationTitle("Categories")
        } detail: {
            NavigationStack(path: $nav.recipePath) {
                RecipeGrid()
            }
            .experienceToolbar()
        }
    }
}

#Preview() {
    TwoColumnContentView()
        .environment(DataModel.shared)
        .environment(NavModel.shared)
}
