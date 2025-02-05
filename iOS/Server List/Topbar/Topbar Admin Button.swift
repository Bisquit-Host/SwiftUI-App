import SwiftUI

struct TopbarAdminButton: View {
    @EnvironmentObject private var store: ValueStore
    
    private let fetchServers: () -> Void
    
    init(_ fetchServers: @escaping () -> Void = {}) {
        self.fetchServers = fetchServers
    }
    
    private var icon: String {
        if store.adminServerList {
            "person.badge.shield.checkmark.fill"
        } else {
            "person.badge.shield.checkmark"
        }
    }
    
    var body: some View {
        if store.devMode {
            Button {
                store.adminServerList.toggle()
                fetchServers()
            } label: {
                Image(systemName: icon)
            }
        }
    }
}

#Preview {
    TopbarAdminButton()
        .environmentObject(ValueStore())
}
