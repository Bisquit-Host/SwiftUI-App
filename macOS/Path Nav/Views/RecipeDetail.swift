//// A detail view the app uses to display the metadata for a given recipe, as well as its related servers
//
//import SwiftUI
//import PteroNet
//
//struct RecipeDetail<Link: View>: View {
//    var recipe: ServerAttributes?
//    var relatedLink: (ServerAttributes) -> Link
//    
//    var body: some View {
//        if let recipe {
//            Content(recipe: recipe, relatedLink: relatedLink)
//                .id(recipe.id)
//        } else {
//            Text("Choose a recipe")
//                .navigationTitle("")
//        }
//    }
//}
//
//private struct Content<Link: View>: View {
//    @Environment(DataModel.self) private var dataModel
//    
//    var recipe: ServerAttributes
//    var relatedLink: (ServerAttributes) -> Link
//    
//    var body: some View {
//        ScrollView {
//            ViewThatFits(in: .horizontal) {
//                wideDetails
//                narrowDetails
//            }
//            .scenePadding()
//        }
//        .navigationTitle(recipe.name)
//    }
//    
//    private var wideDetails: some View {
//        VStack(alignment: .leading) {
//            title
//            
//            HStack(alignment: .top, spacing: 20) {
//                image
//                ingredients
//                
//                Spacer()
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private var narrowDetails: some View {
//#if os(macOS)
//        HStack {
//            narrowDetailsContent
//            
//            Spacer()
//        }
//#else
//        narrowDetailsContent
//#endif
//    }
//    
//    private var narrowDetailsContent: some View {
//        VStack(alignment: narrowDetailsAlignment) {
//            title
//            image
//            ingredients
//        }
//    }
//    
//    private var narrowDetailsAlignment: HorizontalAlignment {
//#if os(macOS)
//        .leading
//#else
//        .center
//#endif
//    }
//    
//    @ViewBuilder
//    private var title: some View {
//#if os(macOS)
//        Text(recipe.name)
//            .largeTitle(.bold)
//#endif
//    }
//    
//    private var image: some View {
//        RecipePhoto(recipe: recipe)
//            .frame(width: 300, height: 300)
//    }
//    
//    private var columns: [GridItem] {[
//        GridItem(.adaptive(minimum: 120, maximum: 120))
//    ]}
//    
//    @ViewBuilder
//    private var ingredients: some View {
//        let padding = EdgeInsets(top: 16, leading: 0, bottom: 8, trailing: 0)
//        
//        VStack(alignment: .leading) {
//            Text("Ingredients")
//                .title2(.bold)
//                .padding(padding)
//            
////            VStack(alignment: .leading) {
////                ForEach(recipe.ingredients) { ingredient in
////                    Text(ingredient.description)
////                }
////            }
//        }
//        .frame(minWidth: 300, alignment: .leading)
//    }
//}
//
////#Preview() {
////    RecipeDetail(recipe: .mock) { _ in
////        EmptyView()
////    }
////    .environment(DataModel.shared)
////}
