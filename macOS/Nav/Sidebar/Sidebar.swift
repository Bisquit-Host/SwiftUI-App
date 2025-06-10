import ScrechKit

struct Sidebar: View {
    @Environment(NavModel.self) private var nav
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var nav = nav
        
        List(selection: $nav.selectedServers) {
            ForEach(vm.servers) { server in
                SidebarServerCard(server)
            }
        }
        .navigationTitle("Servers")
        .frame(minWidth: 300)
        .scrollIndicators(.never)
        .onDisappear {
            nav.selectedServers.removeAll()
        }
        .toolbar {
            SFButton("arrow.trianglehead.2.clockwise.rotate.90") {
                Task {
                    await vm.fetchServers(store.adminServerList)
                }
            }
            .keyboardShortcut("r")
        }
    }
}

#Preview {
    Sidebar()
        .environment(ServerListVM())
        .environment(NavModel())
}
