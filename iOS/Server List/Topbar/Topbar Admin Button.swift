import SwiftUI

struct TopbarAdminButton: View {
    @EnvironmentObject private var store: ValueStore
    
    private let fetchServers: () -> Void
    
    init(_ fetchServers: @escaping () -> Void = {}) {
        self.fetchServers = fetchServers
    }
    
    var body: some View {
        if store.devMode {
            Button {
                store.adminServerList.toggle()
                fetchServers()
            } label: {
                Image(systemName: "person.badge.shield.checkmark")
            }
            .frame(maxWidth: 40)
            .symbolVariant(store.adminServerList ? .fill : .none)
        }
    }
}

#Preview {
    TopbarAdminButton()
        .environmentObject(ValueStore())
}
