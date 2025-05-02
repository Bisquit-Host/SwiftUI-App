// The content view for the two-column navigation split view experience

import SwiftUI

struct TwoColumnContentView: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel

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
            .onDisappear {
                nav.selectedServer.removeAll()
            }
            .experienceToolbar()
            .navigationTitle("Servers")
        } detail: {
            NavigationStack(path: $nav.tabPath) {
                RecipeGrid()
                    .navigationDestination(for: Tabs.self) { tab in
                        Text(tab.title)
                    }
            }
        }
    }
}

#Preview() {
    TwoColumnContentView()
        .environment(DataModel.shared)
        .environment(NavModel.shared)
}
