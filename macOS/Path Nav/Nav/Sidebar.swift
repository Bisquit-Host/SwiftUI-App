import SwiftUI

struct Sidebar: View {
    @Environment(NavModel.self) private var nav
    @Environment(ServerListVM.self) private var vm
    
    var body: some View {
        @Bindable var nav = nav
        
        List(selection: $nav.selectedServer) {
            ForEach(vm.servers) { server in
                SidebarServerCard(server)
            }
        }
        .navigationTitle("Servers")
        .frame(minWidth: 300)
        .onDisappear {
            nav.selectedServer.removeAll()
        }
    }
}

#Preview {
    Sidebar()
        .environment(ServerListVM())
        .environment(NavModel())
}
