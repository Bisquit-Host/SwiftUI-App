import SwiftUI

struct ThreeColumnContentView: View {
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
        } content: {
            if let category = nav.selectedCategory {
                List(selection: $nav.selectedRecipe) {
                    ForEach(dataModel.recipes(in: category)) { recipe in
                        NavigationLink(recipe.name, value: recipe)
                    }
                }
                .navigationTitle(category.localizedName)
                .onDisappear {
//                    if nav.selectedRecipe == nil {
                    nav.selectedCategory = nil
//                    }
                }
                .experienceToolbar()
            } else {
                Text("Choose a category")
                    .navigationTitle("")
            }
        } detail: {
            if let selectedRecipe = nav.selectedRecipe.first {
                Text("Seleted \(nav.selectedRecipe.count)")
                
                RecipeDetail(recipe: selectedRecipe) { relatedRecipe in
                    Button {
                        nav.selectedCategory = relatedRecipe.category
//                        nav.selectedRecipe = relatedRecipe
                    } label: {
                        RecipeTile(relatedRecipe)
                    }
                    .buttonStyle(.plain)
                }
            }
            
//            RecipeDetail(recipe: nav.selectedRecipe) { relatedRecipe in
//                Button {
//                    nav.selectedCategory = relatedRecipe.category
//                    nav.selectedRecipe = relatedRecipe
//                } label: {
//                    RecipeTile(relatedRecipe)
//                }
//                .buttonStyle(.plain)
//            }
        }
    }
}

#Preview() {
    ThreeColumnContentView()
        .environment(NavModel(columnVisibility: .all))
        .environment(DataModel.shared)
}
