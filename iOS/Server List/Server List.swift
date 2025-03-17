import ScrechKit
import TipKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.openURL) private var openUrl
    
    @State private var searchField = ""
    
    var body: some View {
        @Bindable var vm = vm
        
#warning("Present a warning when 2FA is disabled")
        ScrollView(showsIndicators: false) {
            TipView(Tip_ServerCardContextMenu())
            
            if vm.hasFrozenServers {
                TipView(Tip_SuspendedServer()) { action in
                    if action.id == "open-billing" {
                        vm.showBilling = true
                    }
                }
            }
            
            ServerListGrid(vm.filteredServers)
        }
        .padding(.horizontal, 4)
        .environment(vm)
        .navigationBarBackButtonHidden()
        .safariCover($vm.showBilling, url: "https://my.bisquit.host")
        .appStoreOverlay($vm.alertUpdate, id: "1639409934")
        .background(BisquitFall())
        .background {
            Image(.darkBackgroundInfo)
                .resizable()
                .blur(radius: 55, opaque: true)
                .ignoresSafeArea()
        }
        .task {
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button {
                        vm.sheetDiscover = true
                    } label: {
                        Label("Useful links", systemImage: "sparkles")
                    }
                    
                    GameCenterButtons()
                } label: {
                    Image(systemName: "sparkles")
                        .footnote(.bold)
                        .frame(width: 35, height: 35)
                        .background(.ultraThinMaterial, in: .circle)
                }
                .foregroundStyle(.foreground)
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                TopbarAdminButton {
                    vm.fetchServers(store.adminServerList)
                }
                
                ServerListFilter()
                
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
