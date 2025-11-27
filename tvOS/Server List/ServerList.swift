import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(SecurityTasks.self) private var securityTasks
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            ServerListTips()
            
            if securityTasks.alertUpdate {
                ServerListUpdateAlert()
            }
            
            ForEach(vm.filteredServers) {
                ServerCardParent($0)
            }
        }
        .navigationTitle("Servers")
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
        .environment(SecurityTasks())
        .environment(NavState())
        .environmentObject(ValueStore())
}
