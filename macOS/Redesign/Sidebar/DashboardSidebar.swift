import SwiftUI
import Calagopus

struct DashboardSidebar: View {
    @State private var vm = ServerListVM()
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        ScrollView {
            ServerListTips()
                .environment(vm)
            
            ServerListGrid(vm.filteredServers)
        }
        .padding(.horizontal)
        .scrollIndicators(.never)
        .listStyle(.sidebar)
        .frame(minWidth: 400)
        .onFirstAppear {
            vm.loadCachedServers()
        }
        .refreshableTask {
            await vm.fetchServers(store.adminServerList)
            store.updateServers.toggle()
        }
    }
}
