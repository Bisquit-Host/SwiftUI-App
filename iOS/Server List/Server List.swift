import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @State private var searchField = ""
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView(showsIndicators: false) {
            ServerListTips()
                .frame(maxWidth: 440)
            
            ServerListGrid(vm.filteredServers)
        }
        .padding(.horizontal, 4)
        .navigationBarBackButtonHidden()
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
        .onChange(of: searchField) { _, newPrompt in
            withAnimation {
                vm.searchField = newPrompt
            }
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
            Discover()
        }
        .sheet($vm.sheetKeyStorage) {
            CloudKeys($vm.apiKey) {
                Task {
                    await vm.fetchServers(store.adminServerList)
                }
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
                ServerListSettingsButton()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ServerList()
    }
    .darkSchemePreferred()
    .environment(ServerListVM())
    .environmentObject(ValueStore())
}
