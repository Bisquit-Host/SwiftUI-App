import ScrechKit
import TipKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.openURL) private var openUrl
    
    @State private var searchField = ""
    @State private var showSafari = false
    @State private var alertUpdate = false
    
    private var hasFrozenServers: Bool {
        vm.servers.contains {
            $0.isSuspended
        }
    }
    
    var body: some View {
        @Bindable var vm = vm
        
#warning("Present a warning when 2FA is disabled")
        ScrollView(showsIndicators: false) {
            TipView(Tip_ServerCardContextMenu())
            
            if hasFrozenServers {
                TipView(Tip_SuspendedServer()) { action in
                    if action.id == "open-billing" {
                        showSafari = true
                    }
                }
            }
            
            ServerListGrid(vm.filteredServers)
        }
        .padding(.horizontal, 4)
        .environment(vm)
        .navigationBarBackButtonHidden()
        .safariCover($showSafari, url: "https://my.bisquit.host")
        .appStoreOverlay($alertUpdate, id: "1639409934")
        .background(BisquitFall())
        .refreshableTask {
            vm.fetchServers(store.adminServerList)
            store.updateServers.toggle()
        }
        .onChange(of: searchField) { _, search in
            withAnimation {
                vm.searchField = search
            }
        }
        .safeAreaInset(edge: .bottom) {
            if vm.showFilter {
                ServerListFilter($vm.filterBySuspended)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .environment(vm)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                SFButton("sparkles") {
                    vm.sheetDiscover = true
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                TopbarAdminButton {
                    vm.fetchServers(store.adminServerList)
                }
                
                SettingsButton()
                    .environment(vm)
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
        .task {
            if await vm.updateChecker() {
                alertUpdate = true
            }
        }
        .alert("Unknown Error", isPresented: $vm.alertError) {
            
        } message: {
            Text("The list of servers couldn't be loaded. Check your internet connection or contact support")
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
