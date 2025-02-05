import SwiftUI

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
        .sheet($sheetSettings) {
            AppSettings()
        }
        .sheet($vm.sheetKeyStorage) {
            CloudKeys($vm.apiKey)
        }
        .refreshableTask {
            vm.fetchServers(store.adminServerList)
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
