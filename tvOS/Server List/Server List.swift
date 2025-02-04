import SwiftUI

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    private var adminButtonColor: Color {
        store.adminServerList ? .green : .secondary
    }
    
    @State private var sheetOverview = false
    
    var body: some View {
        List {
            if store.devMode {
                Button {
                    store.adminServerList.toggle()
                    vm.fetchServers(store.adminServerList)
                } label: {
                    Label("Admin", systemImage: "person.badge.shield.checkmark")
                        .foregroundStyle(adminButtonColor)
                }
#if DEBUG
                Button("Overview") {
                    sheetOverview = true
                }
#endif
            }
            
            NavigationLink {
                Settings()
            } label: {
                Text("\(Image(systemName: "gear")) Settings")
            }
            
            ForEach(vm.filteredServers) { server in
                Button {
                    navState.navigate(.toPanel(server.id))
                } label: {
                    ServerCard(server)
                }
            }
        }
        .background(BisquitFall())
        .task {
            vm.fetchServers(store.adminServerList)
        }
#if DEBUG
        .sheet($sheetOverview) {
            Overview()
        }
        .environment(vm)
#endif
    }
}

#Preview {
    ServerList()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
