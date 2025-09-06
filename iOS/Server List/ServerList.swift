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
        .navigationBarBackButtonHidden()
        .animation(.default, value: vm.servers)
        .searchable(text: $vm.searchField)
        .safariCover($vm.showBilling, url: "https://my.bisquit.host")
        .background(BisquitFall())
        .background(BackgroundImage())
        .onFirstAppear {
            vm.loadServers()
        }
        .refreshableTask {
            await vm.fetchServers(store.adminServerList)
            store.updateServers.toggle()
        }
        .onChange(of: vm.searchField) {
            guard !(1...2).contains(vm.searchField.count) else {
                return
            }
            
            Task {
                await vm.fetchServers(store.adminServerList, searchPrompt: vm.searchField)
            }
            
            store.updateServers.toggle()
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
        .sheet($vm.sheetKeyStorage) {
            CloudKeys($vm.apiKey) {
                Task {
                    await vm.fetchServers(store.adminServerList)
                }
            }
        }
        .onGamepadPressed(.menu) {
            if !vm.sheetDiscover {
                nav.navigate(.toSettings)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SFButton("sparkles") {
                    vm.sheetDiscover = true
                }
                .tint(Color.yellow.gradient)
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                ServerListAdminButton()
                
                ServerListFilter()
            }
            
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gear") {
                    nav.navigate(.toSettings)
                }
            }
        }
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
