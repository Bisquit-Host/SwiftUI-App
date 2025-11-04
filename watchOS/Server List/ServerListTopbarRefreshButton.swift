import ScrechKit

struct ServerListTopbarRefreshButton: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        SFButton("arrow.triangle.2.circlepath") {
            Task {
                await vm.fetchServers(store.adminServerList)
            }
            
            store.updateServers.toggle()
        }
    }
}

#Preview {
    ServerListTopbarRefreshButton()
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environmentObject(ValueStore())
}
