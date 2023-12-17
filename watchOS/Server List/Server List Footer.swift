import ScrechKit

struct ServerListFooter: View {
    @Environment(ServerListVM.self) private var vm
    
    var body: some View {
        VStack {
            Text("Server count: \(vm.filteredServers.count)")
        }
    }
}

#Preview {
    ServerListFooter()
        .environment(ServerListVM())
}
