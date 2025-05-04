// The content view for the two-column navigation split view navMode

import SwiftUI

struct TwoColumnContentView: View {
    @Environment(NavModel.self) private var nav
    @Environment(ServerListVM.self) private var vm
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            Sidebar()
        } detail: {
            NavigationStack(path: $nav.path) {
                TwoColumnDetailView()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .tab(let tab):
                            ColumnDetail(tab)
                            
                        default:
                            EmptyView()
                        }
                    }
            }
        }
        .task {
            vm.loadServers()
        }
    }
}

#Preview() {
    TwoColumnContentView()
        .environment(ServerListVM())
        .environment(NavModel.shared)
}
