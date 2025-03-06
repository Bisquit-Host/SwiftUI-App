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
            if vm.alertUpdate {
                Section {
                    if let url = URL(string: "https://apps.apple.com/app/bisquit-host/id1639409934") {
                        Button {
                            openUrl(url)
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "link")
                                
                                Text("New Update Available")
                            }
                            .title3()
                        }
                    }
                }
            }
            
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
            
            if !System.lowPowerMode {
                await vm.checkForUpdates()
            }
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
