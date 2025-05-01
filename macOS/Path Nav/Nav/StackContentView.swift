// The content view for the navigation stack view experience

import SwiftUI
import PteroNet

struct StackContentView: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = Tabs.allCases
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.recipePath) {
            List(categories) { category in
                Section {
                    ForEach(dataModel.servers) { recipe in
//                    ForEach(dataModel.recipes(in: category)) { recipe in
                        NavigationLink(recipe.name, value: recipe)
                    }
                } header: {
                    Text(category.title)
                }
            }
            .navigationTitle("Categories")
            .experienceToolbar()
            .navigationDestination(for: ServerAttributes.self) { recipe in
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
