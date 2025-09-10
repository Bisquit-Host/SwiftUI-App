import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            ServerListTopbar()
            
            ServerListUpdateButton()
            
            ServerListGrid(vm.filteredServers)
        }
        .navigationBarBackButtonHidden()
        .task {
            await vm.fetchServers(store.adminServerList)
        }
    }
}

#Preview {
    ServerList()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
