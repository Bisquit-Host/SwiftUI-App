import ScrechKit
import PteroNet
import TipKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetSettings = false
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                TipView(Tip_ServerCardContextMenu())
                
                if vm.hasFrozenServers {
                    TipView(Tip_SuspendedServer()) { action in
                        if action.id == "open-billing" {
                            vm.showBilling = true
                        }
                    }
                }
            }
            .listRowBackground(Color.clear)
            
            ForEach(vm.filteredServers) { server in
                ServerCardParent(server)
            }
        }
        .navigationTitle("Server List")
        .safariCover($vm.showBilling, url: "https://my.bisquit.host")
        .appStoreOverlay($vm.alertUpdate, id: "1639409934")
        .navigationBarBackButtonHidden()
        //#warning("Uncomment")
        //        .toolbar {
        //            ServerListOrnament($sheetSettings)
        //                .environment(vm)
        //
        //#warning("doesn't update servers")
        //            //            ServerListToolbar {
        //            //                vm.fetchServers(store.adminServerList)
        //            //            }
        //        }
        .refreshableTask {
            vm.fetchServers(store.adminServerList)
        }
        .sheet($sheetSettings) {
            AppSettings()
        }
        .sheet($vm.sheetKeyStorage) {
            CloudKeys($vm.apiKey)
        }
        .sheet($vm.sheetDiscover) {
            Discover()
        }
        .task {
            if !System.lowPowerMode {
                await vm.checkForUpdates()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                SFButton("sparkles") {
                    vm.sheetDiscover = true
                }
                
                Menu {
                    MenuButton("Switch Account", icon: "arrow.trianglehead.2.clockwise.rotate.90") {
                        vm.sheetKeyStorage = true
                    }
                    
                    MenuButton("Settings", icon: "gear") {
                        sheetSettings = true
                    }
                    
                    Divider()
                    
                    MenuButton("Log out", role: .destructive, icon: "rectangle.portrait.and.arrow.right") {
                        main {
                            navState.clear()
                            store.isApiKeyValid = false
                            Keychain.delete(key: "selectedApiKey")
                        }
                    }
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
    }
}

#Preview {
    ServerList()
        .padding()
        .glassBackgroundEffect()
        .environment(ServerListVM())
        .environmentObject(ValueStore())
}
