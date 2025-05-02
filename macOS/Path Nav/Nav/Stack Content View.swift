// The content view for the navigation stack view experience

import ScrechKit
import PteroNet

enum Route: Hashable, Codable {
    case server(ServerAttributes),
         tab(Tabs)
}

struct StackContentView: View {
    @State private var sectionsVM = PanelSectionVM()
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = Tabs.allCases
    
    @State private var sheetCustomization = false
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
            Section {
                Text(nav.path.description)
            }
            
            List(dataModel.servers) { server in
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
            .experienceToolbar()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .server(let server):
                    List(selection: $nav.selectedTab) {
                        Section {
                            Text(nav.path.description)
                        }
                        
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
                    .toolbar {
                        SFButton("pencil") {
                            sheetCustomization = true
                        }
                    }
                    
                case .tab(let tab):
                    VStack {
                        Text(nav.path.description)
                        
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
        .environment(DataModel.shared)
        .environment(NavModel.shared)
}
