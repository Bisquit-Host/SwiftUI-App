// The content view for the two-column navigation split view navMode

import SwiftUI

struct TwoColumnContentView: View {
    @Environment(NavModel.self) private var nav
    @Environment(ServerListVM.self) private var vm
    
    @FocusState private var focusedList: FocusedList?
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            Sidebar()
                .focused($focusedList, equals: .serverList)
        } detail: {
            NavigationStack(path: $nav.path) {
                TwoColumnDetailView()
                    .focused($focusedList, equals: .sectionList)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .tab(let tab):
                            if let server = nav.selectedServers.first {
                                ColumnDetail(tab, server: server, focusedList: $focusedList)
                            } else {
                                Text("Multiple servers selected")
                            }
                            
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
