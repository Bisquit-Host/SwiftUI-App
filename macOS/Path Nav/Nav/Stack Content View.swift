// The content view for the navigation stack view navMode

import SwiftUI

struct StackContentView: View {
    @State private var sectionsVM = PanelSectionVM()
    @Environment(NavModel.self) private var nav
    @Environment(ServerListVM.self) private var vm
    
    private let categories = Tabs.allCases
    
    @State private var sheetCustomization = false
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
            List(vm.servers) { server in
                NavigationLink(value: Route.server(server)) {
                    VStack(alignment: .leading) {
                        Text(server.name)
                        
                        Text(server.description)
                            .secondary()
                            .footnote()
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Servers")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .server:
                    List(selection: $nav.selectedTab) {
                        ForEach(Tabs.allCases) { tab in
                            NavigationLink(tab.title, value: Route.tab(tab))
                        }
                    }
                    .navigationTitle(nav.selectedServer.first?.name ?? "Multiple servers selected")
                    .onAppear {
                        try? nav.save()
                    }
                    .onDisappear {
                        nav.selectedTab = nil
                    }
                    
                case .tab(let tab):
                    VStack {
                        Text(tab.title)
                            .onAppear {
                                try? nav.save()
                            }
                    }
                }
            }
        }
        .sheet($sheetCustomization) {
            NavigationStack {
                PanelSectionList()
                    .environment(sectionsVM)
            }
            .frame(minHeight: 500)
        }
    }
}

#Preview() {
    StackContentView()
        .environment(ServerListVM())
        .environment(NavModel.shared)
}
