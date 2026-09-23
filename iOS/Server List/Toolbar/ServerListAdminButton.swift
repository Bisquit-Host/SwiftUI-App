import ScrechKit

struct ServerListAdminButton: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        if store.devMode {
            AsyncButton(action: toggleAndFetch) {
                Image(systemName: "person.badge.shield.checkmark")
            }
            .symbolVariant(store.adminServerList ? .fill : .none)
        }
    }
    
    private func toggleAndFetch() async {
        store.adminServerList.toggle()
        
        Task {
            await vm.fetchServers(store.adminServerList)
        }
    }
}

#Preview {
    ServerListAdminButton()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
        .environment(ServerListVM())
}
