import SwiftUI

struct DashboardSidebar: View {
    @State private var vm = ServerListVM()
    @Binding var selection: SidebarItem?
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List(selection: $selection) {
            Section {
                ServerListGrid(vm.filteredServers)
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 400)
        .onFirstAppear {
            vm.loadServers()
        }
        .refreshableTask {
            await vm.fetchServers(store.adminServerList)
            store.updateServers.toggle()
        }
    }
}
