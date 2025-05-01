import SwiftUI

struct ThreeColumnContentView: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = Tabs.allCases
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            //            List(categories, selection: $nav.selectedCategory) { category in
            //                NavigationLink(category.localizedName, value: category)
            //            }
            //            if let server = nav.selectedServer {
            List(selection: $nav.selectedServer) {
                ForEach(dataModel.servers) { server in
                    //                    ForEach(dataModel.recipes(in: category)) { recipe in
                    NavigationLink(value: server) {
                        VStack(alignment: .leading) {
                            Text(server.name)
                            
                            Text(server.description)
                                .secondary()
                                .footnote()
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .frame(minWidth: 200)
            .navigationTitle(nav.selectedServer.first?.name ?? "Multiple servers selected")
            .onDisappear {
                //                    if nav.selectedServer == nil {
                nav.selectedServer.removeAll()
                //                    }
            }
            .experienceToolbar()
            .navigationTitle("Servers")
            //            }
        } content: {
//            if let selectedServer = nav.selectedServer {
                List(selection: $nav.selectedTab) {
                    ForEach(Tabs.allCases) { tab in
                        //                    ForEach(dataModel.recipes(in: category)) { recipe in
                        NavigationLink(tab.title, value: tab)
                    }
                }
                .navigationTitle(nav.selectedServer.first?.name ?? "Multiple servers selected")
                .onDisappear {
                    nav.selectedTab = nil
                }
                .experienceToolbar()
//            } else {
//                Text("Choose a server")
//                    .navigationTitle("")
//            }
        } detail: {
            if let selectedRecipe = nav.selectedServer.first {
                Text("Seleted \(nav.selectedServer.count)")
                
                RecipeDetail(recipe: selectedRecipe) { relatedRecipe in
                    Button {
                        //                        nav.selectedCategory = relatedRecipe.category //
                        //                        nav.selectedServer = relatedRecipe
                    } label: {
                        RecipeTile(relatedRecipe)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            //            RecipeDetail(recipe: nav.selectedServer) { relatedRecipe in
            //                Button {
            //                    nav.selectedCategory = relatedRecipe.category
            //                    nav.selectedServer = relatedRecipe
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
