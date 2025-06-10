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
        
        VStack {
            TipView(Tip_ServerCardContextMenu())
                .padding(.horizontal, 25)
                .tipCornerRadius(14)
            
            if vm.hasFrozenServers {
                TipView(Tip_SuspendedServer()) { action in
                    if action.id == "open-billing" {
                        vm.showBilling = true
                    }
                }
                .padding(.horizontal, 25)
                .tipCornerRadius(14)
            }
            
            List {
                ForEach(vm.filteredServers) { server in
                    ServerCardParent(server)
                }
            }
        }
        .navigationTitle("Server List")
        .safariCover($vm.showBilling, url: "https://my.bisquit.host")
        .navigationBarBackButtonHidden()
        .refreshableTask {
            await vm.fetchServers(store.adminServerList)
        }
        .sheet($sheetSettings) {
            NavigationView {
                AppSettings()
            }
        }
        .sheet($vm.sheetKeyStorage) {
            CloudKeys($vm.apiKey)
        }
        .sheet($vm.sheetDiscover) {
            Discover()
        }
        .toolbar {
#warning("Uncomment")
            //        .toolbar {
            //            ServerListOrnament($sheetSettings)
            //                .environment(vm)
            //
            //        #warning("doesn't update servers")
            //            //            ServerListToolbar {
            //            //                vm.fetchServers(store.adminServerList)
            //            //            }
            //        }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button {
                        vm.sheetDiscover = true
                    } label: {
                        Label("Useful links", systemImage: "sparkles")
                    }
                    
                    GameCenterButtons()
                } label: {
                    Image(systemName: "sparkles")
                }
                
                Menu {
                    MenuButton("Switch account", icon: "arrow.trianglehead.2.clockwise.rotate.90") {
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
