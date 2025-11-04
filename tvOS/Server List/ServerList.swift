import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(UpdateChecker.self) private var updater
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            if updater.alertUpdate {
                ServerListUpdateAlert()
            }
            
            ForEach(vm.filteredServers) {
                ServerCardParent($0)
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
            }
        }
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
