// The content view for the navigation stack view experience

import SwiftUI

struct StackContentView: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = Category.allCases
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.recipePath) {
            List(categories) { category in
                Section {
                    ForEach(dataModel.recipes(in: category)) { recipe in
                        NavigationLink(recipe.name, value: recipe)
                    }
                } header: {
                    Text(category.localizedName)
                }
            }
            .navigationTitle("Categories")
            .experienceToolbar()
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetail(recipe: recipe) { relatedRecipe in
                    Button {
                        nav.recipePath.append(relatedRecipe)
                    } label: {
                        RecipeTile(relatedRecipe)
                    }
                    .buttonStyle(.plain)
                }
                .experienceToolbar()
            }
        }
    }
}

#Preview() {
    StackContentView()
        .environment(DataModel.shared)
        .environment(NavModel.shared)
}
