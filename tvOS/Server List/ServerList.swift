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
        .task {
            await vm.fetchServers(store.adminServerList)
        }
        .toolbar {
            NavigationLink {
                CalagopusSettings()
            } label: {
                Label("Settings", systemImage: "")
            }
            
            if store.devMode {
                Button("Admin", systemImage: "", action: toggleAdminServerList)
                    .foregroundStyle(store.adminServerList ? .primary : .secondary)
            }
        }
    }
    
    private func toggleAdminServerList() {
        store.adminServerList.toggle()
        
        Task {
            await vm.fetchServers(store.adminServerList)
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
