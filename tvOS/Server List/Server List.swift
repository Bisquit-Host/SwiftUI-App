import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.openURL) private var openUrl
    
    @State private var sheetOverview = false
    
    var body: some View {
        @Bindable var vm = vm
        
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
        .alert("New Update Available", isPresented: $vm.alertUpdate) {
            if let url = URL(string: "https://apps.apple.com/app/bisquit-host/id1639409934") {
                Button("Update", role: .destructive) {
                    openUrl(url)
                }
            }
        } message: {
            Text("Update now to enjoy the latest improvements!")
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
        .task {
            await vm.checkForUpdates()
        }
#endif
    }
}

#Preview {
    ServerList()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
