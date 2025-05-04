import SwiftUI

struct ThreeColumnContentView: View {
    @State private var sectionsVM = PanelSectionVM()
    @Environment(NavModel.self) private var nav
    @Environment(ServerListVM.self) private var vm
    
    @State private var sheetCustomization = false
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            Sidebar()
        } content: {
            ThreeColumnContent()
        } detail: {
            ColumnDetail()
        }
        .backgroundBlur()
        .task {
            vm.loadServers()
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
}
