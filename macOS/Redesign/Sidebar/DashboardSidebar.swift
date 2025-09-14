import SwiftUI

struct DashboardSidebar: View {
    @State private var vm = ServerListVM()
    @EnvironmentObject private var store: ValueStore
    
    @Binding private var selection: SidebarItem?
    
    init(_ selection: Binding<SidebarItem?>) {
        _selection = selection
    }
    
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
