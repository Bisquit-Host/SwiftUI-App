import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.openURL) private var openUrl
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            ServerListTopbar()
            
            ServerListGrid(vm.filteredServers)
        }
        .navigationTitle("Bisquit.Host")
        .navigationBarBackButtonHidden()
        .task {
            vm.fetchServers(store.adminServerList)
            
            if !System.lowPowerMode {
                await vm.checkForUpdates()
            }
        }
        .alert("New Update Available", isPresented: $vm.alertUpdate) {
            if let url = URL(string: "https://apps.apple.com/app/bisquit-host/id1639409934") {
                Button("Update", role: .destructive) {
                    openUrl(url)
                }
            }
        } message: {
            Text("Update now to enjoy the latest improvements!")
        }
    }
}

#Preview {
    ServerList()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
