import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @Environment(UpdateChecker.self) private var updater
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.openURL) private var openUrl
    
    @State private var sheetOverview = false
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            if updater.alertUpdate {
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
                    navState.navigate(.toPanel(server))
                } label: {
                    ServerCard(server)
                }
            }
        }
        .background(BisquitFall())
        .task {
            await vm.fetchServers(store.adminServerList)
        }
        .toolbar {
            NavigationLink("Settings") {
                AppSettings()
            }
            
            if store.devMode {
                Button("Admin") {
                    store.adminServerList.toggle()
                    
                    Task {
                        await vm.fetchServers(store.adminServerList)
                    }
                }
                .foregroundStyle(store.adminServerList ? .primary : .secondary)
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
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environment(UpdateChecker())
        .environment(NavState())
        .environmentObject(ValueStore())
}
