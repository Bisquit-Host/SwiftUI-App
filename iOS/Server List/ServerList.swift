import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView(showsIndicators: false) {
            ServerListTips()
                .frame(maxWidth: 440)
            
            ServerListGrid(vm.filteredServers)
        }
        .navigationTitle("Servers")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .animation(.default, value: vm.servers)
        .searchable(text: $vm.searchField)
        .safariCover($vm.showBilling, url: "https://my.bisquit.host")
        .background(BisquitFall())
        .background(BackgroundImage())
        .serverListToolbar()
        .onFirstAppear {
            vm.loadServers()
        }
        .refreshableTask {
            await vm.fetchServers(store.adminServerList)
            store.updateServers.toggle()
        }
        .onChange(of: vm.searchField) {
            search()
        }
        .overlay {
            if vm.filteredServers.isEmpty, !vm.searchField.isEmpty {
                ContentUnavailableView.search(text: vm.searchField)
            }
        }
        .sheet($vm.sheetGuide) {
            Guide()
        }
        .sheet($vm.sheetDiscover) {
            NavigationStack {
                Discover()
            }
        }
        .onGamepadPressed(.menu, cooldown: 1) {
            if !vm.sheetDiscover {
                nav.navigate(.toSettings)
            }
        }
    }
    
    private func search() {
        guard !(1...2).contains(vm.searchField.count) else {
            return
        }
        
        Task {
            await vm.fetchServers(store.adminServerList, searchPrompt: vm.searchField)
        }
        
        store.updateServers.toggle()
    }
}

#Preview {
    NavigationStack {
        ServerList()
    }
    .environment(ServerListVM())
    .environment(NavState())
    .environmentObject(ValueStore())
}
