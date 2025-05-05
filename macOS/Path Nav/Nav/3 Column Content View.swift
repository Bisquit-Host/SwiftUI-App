import SwiftUI

enum FocusedList: String, Hashable {
    case serverList, sectionList
}

struct ThreeColumnContentView: View {
    @State private var sectionsVM = PanelSectionVM()
    @Environment(NavModel.self) private var nav
    @Environment(ServerListVM.self) private var vm
    
    @State private var sheetCustomization = false
    
    @FocusState private var focusedList: FocusedList?
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            Sidebar()
                .focused($focusedList, equals: .serverList)
        } content: {
            ThreeColumnContent()
                .focused($focusedList, equals: .sectionList)
        } detail: {
            if let server = nav.selectedServers.first {
                ColumnDetail(server: server)
            } else {
                Text("Multiple servers selected")
            }
        }
        .backgroundBlur()
        .task {
            vm.loadServers()
        }
        .onGamepadPressed(.dpadDown) {
            moveSelectionDown()
        }
        .onGamepadPressed(.dpadUp) {
            moveSelectionUp()
        }
        .onGamepadPressed(.dpadLeft) {
            focusedList = .serverList
        }
        .onGamepadPressed(.dpadRight) {
            focusedList = .sectionList
        }
        .sheet($sheetCustomization) {
            NavigationStack {
                PanelSectionList()
                    .environment(sectionsVM)
            }
            .frame(minHeight: 500)
        }
    }
    
    private func moveSelectionDown() {
        switch focusedList {
        case .serverList:
            guard let selectedServer = nav.selectedServers.first,
                  let index = vm.servers.firstIndex(of: selectedServer),
                  index + 1 < vm.servers.count
            else {
                return
            }
            
            nav.selectedServers = [vm.servers[index + 1]]
            
        case .sectionList:
            let tabs = PanelTab.allCases
            
            guard let selectedTab = nav.selectedTab,
                  let index = tabs.firstIndex(of: selectedTab),
                  index + 1 < tabs.count
            else {
                return
            }
            
            nav.selectedTab = tabs[index + 1]
            
        default:
            break
        }
    }
    
    private func moveSelectionUp() {
        switch focusedList {
        case .serverList:
            guard let selectedServer = nav.selectedServers.first,
                  let index = vm.servers.firstIndex(of: selectedServer),
                  index - 1 >= 0
            else {
                return
            }
            
            nav.selectedServers = [vm.servers[index - 1]]
            
        case .sectionList:
            let tabs = PanelTab.allCases
            
            guard let selectedTab = nav.selectedTab,
                  let index = tabs.firstIndex(of: selectedTab),
                  index - 1 >= 0
            else {
                return
            }
            
            nav.selectedTab = tabs[index - 1]
            
        default:
            break
        }
    }
}

#Preview() {
    ThreeColumnContentView()
        .environment(NavModel(columnVisibility: .all))
}
