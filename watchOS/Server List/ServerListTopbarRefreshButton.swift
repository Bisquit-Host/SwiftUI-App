import ScrechKit

struct ServerListTopbarRefreshButton: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        AsyncButton {
            await vm.fetchServers(store.adminServerList)
            store.updateServers.toggle()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
    }
}

#Preview {
    ServerListTopbarRefreshButton()
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environmentObject(ValueStore())
}
