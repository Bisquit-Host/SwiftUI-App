import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetOverview = false
    
    var body: some View {
        List {
            ForEach(vm.filteredServers) { server in
                Button {
                    navState.navigate(.toPanel(server.id))
                } label: {
                    ServerCard(server)
                }
            }
        }
        .background(BisquitFall())
        .task {
            vm.fetchServers(store.adminServerList)
        }
        .toolbar {
            NavigationLink("Settings") {
                Settings()
            }
            
            if store.devMode {
                Button {
                    store.adminServerList.toggle()
                    vm.fetchServers(store.adminServerList)
                } label: {
                    Text("Admin")
                        .foregroundStyle(store.adminServerList ? .primary : .secondary)
                }
#if DEBUG
                Button("Overview") {
                    sheetOverview = true
                }
#endif
            }
        }
#if DEBUG
        .sheet($sheetOverview) {
            Overview()
        }
        .environment(vm)
#endif
    }
}

#Preview {
    ServerList()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
