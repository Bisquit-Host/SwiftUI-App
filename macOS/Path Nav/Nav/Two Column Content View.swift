// The content view for the two-column navigation split view experience

import SwiftUI

struct TwoColumnContentView: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = Tabs.allCases
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            List(selection: $nav.selectedServer) {
                ForEach(dataModel.servers) { server in
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
                nav.selectedServer.removeAll()
            }
            .experienceToolbar()
            .navigationTitle("Servers")
        } detail: {
            NavigationStack(path: $nav.recipePath) {
//                if let selectedTab = nav.selectedTab {
//                    Text("Selected \(selectedTab.title)")
//                } else {
//                    Text("Not selected")
//                }
                
                RecipeGrid()
            }
        }
    }
}

#Preview() {
    TwoColumnContentView()
        .environment(DataModel.shared)
        .environment(NavModel.shared)
}
