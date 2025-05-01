// A grid of recipe tiles, based on a given recipe category

import SwiftUI
import PteroNet

struct RecipeGrid: View {
    @Environment(NavModel.self) private var navigationModel
    @Environment(DataModel.self) private var dataModel
    
    var body: some View {
        if let category = navigationModel.selectedTab {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(dataModel.servers) { recipe in
//                    ForEach(vm.recipes(in: category)) { recipe in
                        NavigationLink(value: recipe) {
                            RecipeTile(recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle(category.title)
            .navigationDestination(for: ServerAttributes.self) { recipe in
//                RecipeDetail(recipe: recipe) { relatedRecipe in
//                    Button {
//                        navigationModel.recipePath.append(relatedRecipe)
//                    } label: {
//                        RecipeTile(relatedRecipe)
//                    }
//                    .buttonStyle(.plain)
//                }
//                .experienceToolbar()
            }
        } else {
            Text("Choose a category")
                .navigationTitle("")
        }
    }
    
    var columns: [GridItem] {
        [ GridItem(.adaptive(minimum: 240)) ]
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
