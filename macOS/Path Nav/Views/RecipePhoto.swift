// A photo view for a given recipe, displaying the recipe's image or a placeholder

import SwiftUI

struct RecipePhoto: View {
    var recipe: Recipe
    
    var body: some View {
        if let imageName = recipe.imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            ZStack {
                Rectangle()
                    .fill(.tertiary)
                
                Image(systemName: "camera")
                    .fontSize(64)
                    .secondary()
            }
        }
    }
}

#Preview() {
    RecipePhoto(recipe: .mock)
}
