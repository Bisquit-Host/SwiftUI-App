// The content view for the two-column navigation split view navMode

import SwiftUI

struct TwoColumnContentView: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            Sidebar()
        } detail: {
            NavigationStack(path: $nav.path) {
                RecipeGrid()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .tab(let tab):
                            VStack {
                                Text(tab.title)
                                    .onAppear {
                                        try? nav.save()
                                    }
                            }
                            
                        default:
                            EmptyView()
                        }
                    }
            }
        }
    }
}

#Preview() {
    TwoColumnContentView()
        .environment(ServerListVM())
        .environment(NavModel.shared)
}
