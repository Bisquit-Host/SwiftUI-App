import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        @Bindable var binding = vm
        
        ScrollView {
            ServerListTopbar()
            
            ServerListGrid(vm.filteredServers)
        }
        .navigationTitle("Bisquit.Host")
        .navigationBarBackButtonHidden()
        .task {
            vm.fetchServers(settings.adminServerList)
        }
    }
}

#Preview {
    ServerList()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(SettingsStorage())
}
