import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetSettings = false
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            ForEach(vm.filteredServers) { server in
                ServerCardParent(server)
            }
        }
        .padding(.horizontal, 4)
        .navigationTitle("Server List")
        .navigationBarBackButtonHidden()
        //        #warning("Uncomment")
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
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                SFButton("sparkles") {
                    vm.sheetDiscover = true
                }
                
                SFButton("gear") {
                    sheetSettings = true
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
