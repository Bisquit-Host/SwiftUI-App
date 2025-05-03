import SwiftUI

struct Sidebar: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        @Bindable var nav = nav
        
        List(selection: $nav.selectedServer) {
            ForEach(vm.servers) { server in
                NavigationLink(value: server) {
                    VStack(alignment: .leading) {
                        Text(server.name)
                        
                        Text(server.description)
                            .secondary()
                            .footnote()
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Servers")
        .frame(minWidth: 300)
        .experienceToolbar()
        .onDisappear {
            nav.selectedServer.removeAll()
        }
    }
}

#Preview {
    Sidebar()
        .environment(DataModel())
        .environment(NavModel())
}
