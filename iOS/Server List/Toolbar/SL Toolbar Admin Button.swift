import ScrechKit

struct SLToolbarAdminButton: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        if store.devMode {
            SFButton("person.badge.shield.checkmark") {
                toggleAndFetch()
            }
            .symbolVariant(store.adminServerList ? .fill : .none)
        }
    }
    
    private func toggleAndFetch() {
        store.adminServerList.toggle()
        
        Task {
            await vm.fetchServers(store.adminServerList)
        }
    }
}

#Preview {
    SLToolbarAdminButton()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
