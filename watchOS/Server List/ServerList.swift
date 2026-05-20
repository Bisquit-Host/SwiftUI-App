import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            ServerListUpdateButton()
            ServerListGrid(vm.filteredServers)
        }
        .navigationTitle("Servers")
        .navigationBarBackButtonHidden()
        .task {
            await vm.fetchServers(store.adminServerList)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                ServerListTopbarRefreshButton()
            }
#warning("Settings disabled")
            //            ToolbarItem(placement: .cancellationAction) {
            //                ServerListTopbarSettingsButton()
            //            }
        }
    }
}

#Preview {
    ServerList()
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
