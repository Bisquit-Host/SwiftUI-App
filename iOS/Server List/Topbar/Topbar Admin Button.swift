import SwiftUI

struct TopbarAdminButton: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        if store.devMode {
            Button {
                store.adminServerList.toggle()
                
                Task {
                    await vm.fetchServers(store.adminServerList)
                }
            } label: {
                Image(systemName: "person.badge.shield.checkmark")
            }
            .symbolVariant(store.adminServerList ? .fill : .none)
        }
    }
}

#Preview {
    TopbarAdminButton()
        .environmentObject(ValueStore())
}
