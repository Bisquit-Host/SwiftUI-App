import SwiftUI
import PteroNet

struct DashboardSidebar: View {
    @State private var vm = ServerListVM()
    @EnvironmentObject private var store: ValueStore
    
    @Binding private var selection: SidebarItem?
    
    init(_ selection: Binding<SidebarItem?>) {
        _selection = selection
    }
    
    var body: some View {
        ScrollView {
            ServerListGrid(vm.filteredServers)
        }
        .padding(.horizontal)
        .scrollIndicators(.never)
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
