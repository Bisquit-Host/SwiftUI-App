import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    
    var body: some View {
        ForEach(vm.servers, id: \.id) { server in
            ServerCard(server)
        }
    }
}

#Preview {
    ServerList()
        .padding()
}
