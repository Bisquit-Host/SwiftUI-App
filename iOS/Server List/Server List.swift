import ScrechKit
import TipKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    @State private var searchField = ""
    @State private var showSafari = false
    
    var body: some View {
        @Bindable var vm = vm
        
#warning("Present a warning when 2FA is disabled")
        
        ScrollView(showsIndicators: false) {
            TipView(Tip_ServerCardContextMenu())
            
            if vm.servers.contains(where: {
                $0.isSuspended
            }) {
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
        .searchable(text: $searchField)
        .navigationBarBackButtonHidden()
        .safariCover($showSafari, url: "https://my.bisquit.host")
        .background {
            BisquitFall()
        }
        .refreshable {
            vm.fetchServers(settings.adminServerList)
            settings.updateServers.toggle()
        }
        .onChange(of: searchField) { _, search in
            withAnimation {
                vm.searchField = search
            }
        }
        .safeAreaInset(edge: .bottom) {
            ServerListFilter($vm.filterBySuspended)
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(vm)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                SFButton("sparkles") {
                    vm.sheetDiscover = true
                }
                
                TopbarGridButton()
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                TopbarAdminButton {
                    vm.fetchServers(settings.adminServerList)
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
                vm.fetchServers(settings.adminServerList)
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
    .environmentObject(SettingsStorage())
}
