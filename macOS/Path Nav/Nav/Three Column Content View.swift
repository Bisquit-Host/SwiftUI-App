import ScrechKit

struct ThreeColumnContentView: View {
    @State private var sectionsVM = PanelSectionVM()
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = Tabs.allCases
    
    @State private var sheetCustomization = false
    
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
        } content: {
            if nav.selectedTab != nil {
                List(selection: $nav.selectedTab) {
                    ForEach(Tabs.allCases) { tab in
                        NavigationLink(tab.title, value: tab)
                    }
                }
                .navigationTitle(nav.selectedServer.first?.name ?? "Multiple servers selected")
                .onDisappear {
                    nav.selectedTab = nil
                }
                .toolbar {
                    SFButton("pencil") {
                        sheetCustomization = true
                    }
                }
            } else {
                Text("Choose a server")
                    .navigationTitle("")
            }
        } detail: {
            switch nav.selectedTab {
            case .info:
                Text("Info")
                
            default:
                Text("Select a tab")
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
    ThreeColumnContentView()
        .environment(NavModel(columnVisibility: .all))
        .environment(DataModel.shared)
}
