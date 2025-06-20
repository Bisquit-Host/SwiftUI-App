import ScrechKit

struct TopbarAdminButton: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        if store.devMode {
            SFButton("person.badge.shield.checkmark") {
                store.adminServerList.toggle()
                
                Task {
                    await vm.fetchServers(store.adminServerList)
                }
            }
            .symbolVariant(store.adminServerList ? .fill : .none)
        }
    }
}

#Preview {
    TopbarAdminButton()
        .environmentObject(ValueStore())
}
