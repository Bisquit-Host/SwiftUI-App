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
        .appStoreOverlay($vm.alertUpdate, id: "1639409934")
        .background(BisquitFall())
        .background(BackgroundImage())
        .onFirstAppear {
            vm.loadServers()
            
            if !System.lowPowerMode {
                await vm.checkForUpdates()
            }
        }
        .refreshableTask {
            vm.fetchServers(store.adminServerList)
            store.updateServers.toggle()
        }
        .onChange(of: searchField) { _, search in
            withAnimation {
                vm.searchField = search
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
                vm.fetchServers(store.adminServerList)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button {
                        vm.sheetDiscover = true
                    } label: {
                        Label("Useful links", systemImage: "link")
                    }
                    
                    GameCenterButtons()
                } label: {
                    Image(systemName: "sparkles")
                        .footnote(.bold)
                        .frame(35)
                        .background(.ultraThinMaterial, in: .circle)
                }
                .foregroundStyle(.foreground)
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                TopbarAdminButton()
                
                ServerListFilter()
                
                SettingsButton()
            }
        }
    }
}

#Preview {
    NavigationView {
        ServerList()
    }
    .environment(ServerListVM())
    .environment(NavState())
    .environmentObject(ValueStore())
}
