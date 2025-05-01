// The content view for the navigation stack view experience

import ScrechKit
import PteroNet

struct StackContentView: View {
    @State private var sectionsVM = PanelSectionVM()
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = Tabs.allCases
    
    @State private var sheetCustomization = false
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.recipePath) {
            List(dataModel.servers) { server in
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
            .navigationTitle("Servers")
            .experienceToolbar()
            .navigationDestination(for: ServerAttributes.self) { server in
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
