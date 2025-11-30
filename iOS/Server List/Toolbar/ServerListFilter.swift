import ScrechKit

struct ServerListFilter: View {
    @Environment(ServerListVM.self) private var vm
    
    private var filterEnabled: Bool {
        vm.filterByNotSuspended || !vm.displayedNode.isEmpty
    }
    
    var body: some View {
        Menu {
            if vm.hasSuspendedServers {
                Button("Not suspended", systemImage: vm.filterByNotSuspended ? "snowflake.circle.fill" : "snowflake") {
                    filterByNotSuspended()
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .symbolVariant(filterEnabled ? .fill : .none)
        }
    }
    
    private func filterByNotSuspended() {
        withAnimation {
            vm.filterByNotSuspended.toggle()
        }
    }
}

#Preview {
    ServerListFilter()
        .darkSchemePreferred()
        .environment(ServerListVM())
}
