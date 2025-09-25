import ScrechKit

struct Sidebar: View {
    @Environment(NavModel.self) private var nav
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var nav = nav
        
        List(selection: $nav.selectedServers) {
            ForEach(vm.servers) {
                SidebarServerCard($0)
            }
        }
        .navigationTitle("Servers")
        .frame(minWidth: 300)
        .scrollIndicators(.never)
        .onDisappear {
            nav.selectedServers.removeAll()
        }
        .toolbar {
            SFButton("arrow.trianglehead.2.clockwise.rotate.90") {
                fetch()
            }
            .keyboardShortcut("r")
        }
    }
    
    private func fetch() {
        Task {
            await vm.fetchServers(store.adminServerList)
        }
    }
}

#Preview {
    NavigationStack {
        Sidebar()
    }
    .darkSchemePreferred()
    .environment(ServerListVM())
    .environment(NavModel())
    .environmentObject(ValueStore())
}
