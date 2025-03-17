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
                    .footnote(.bold)
                    .frame(width: 35, height: 35)
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
