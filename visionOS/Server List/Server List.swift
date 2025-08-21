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
            TipView(TipServerCardContextMenu())
                .padding(.horizontal, 25)
                .tipCornerRadius(14)
            
            if vm.hasFrozenServers {
                TipView(TipSuspendedServer()) { action in
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
            NavigationStack {
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
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Useful links", systemImage: "sparkles") {
                    vm.sheetDiscover = true
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
        .environment(NavState())
        .environmentObject(ValueStore())
}
