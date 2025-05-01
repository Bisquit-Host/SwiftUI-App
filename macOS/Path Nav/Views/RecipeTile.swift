// A recipe tile, displaying the recipe's photo and name

import SwiftUI

struct RecipeTile: View {
    private var recipe: Recipe
    
    init(_ recipe: Recipe) {
        self.recipe = recipe
    }
    
    @State private var isHovering = false
    
    var body: some View {
        VStack(alignment: .leading) {
            RecipePhoto(recipe: recipe)
                .aspectRatio(1, contentMode: .fill)
                .frame(maxWidth: 240, maxHeight: 240)
            
            Text(recipe.name)
                .lineLimit(2, reservesSpace: true)
        }
        .tint(.primary)
        .scaleEffect(CGSize(width: scale, height: scale))
        .onHover {
            isHovering = $0
        }
    }
    
    private var scale: CGFloat {
        isHovering ? 1.05 : 1
    }
}

#Preview() {
    RecipeTile(.mock)
}
