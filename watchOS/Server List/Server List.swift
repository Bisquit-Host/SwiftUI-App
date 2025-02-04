import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        ScrollView {
            ServerListTopbar()
            
            ServerListGrid(vm.filteredServers)
        }
        .navigationTitle("Bisquit.Host")
        .navigationBarBackButtonHidden()
        .task {
            vm.fetchServers(store.adminServerList)
        }
    }
}

#Preview {
    ServerList()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
