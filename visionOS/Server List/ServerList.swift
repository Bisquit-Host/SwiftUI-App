import ScrechKit
import PteroNet
import TipKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetSettings = false
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            ServerListTips()
            
            List {
                ForEach(vm.filteredServers) {
                    ServerCardParent($0)
                }
            }
        }
        .navigationTitle("Server List")
        .safariCover($vm.showBilling, url: "https://my.bisquit.host")
        .navigationBarBackButtonHidden()
        .task {
            await vm.fetchServers(store.adminServerList)
        }
        .refreshable {
            await vm.fetchServers(store.adminServerList)
            store.adminServerList.toggle()
        }
        .sheet($sheetSettings) {
            NavigationStack {
                AppSettings()
            }
        }
        .sheet($vm.sheetDiscover) {
            Discover()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Useful links", systemImage: "sparkles") {
                    vm.sheetDiscover = true
                }
                
                Button("Settings", systemImage: "gear") {
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
        .environment(NavState())
        .environmentObject(ValueStore())
}
