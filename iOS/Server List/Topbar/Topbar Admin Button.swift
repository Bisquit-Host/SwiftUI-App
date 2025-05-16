import SwiftUI

struct TopbarAdminButton: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        if store.devMode {
            Button {
                store.adminServerList.toggle()
                vm.fetchServers(store.adminServerList)
            } label: {
                Image(systemName: "person.badge.shield.checkmark")
                    .footnote(.bold)
                    .frame(35)
                    .background(.ultraThinMaterial, in: .circle)
            }
            .symbolVariant(store.adminServerList ? .fill : .none)
            .foregroundStyle(.foreground)
        }
    }
}

#Preview {
    TopbarAdminButton()
        .environmentObject(ValueStore())
}
