import ScrechKit

struct ThreeColumnContentView: View {
    @State private var sectionsVM = PanelSectionVM()
    @Environment(NavModel.self) private var nav
    
    private let categories = Tabs.allCases
    
    @State private var sheetCustomization = false
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            Sidebar()
        } content: {
            if !nav.selectedServer.isEmpty {
                List(selection: $nav.selectedTab) {
                    ForEach(Tabs.allCases) { tab in
                        NavigationLink(tab.title, value: tab)
                    }
                }
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
            Text(nav.selectedTab?.title ?? "Select a section")
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
