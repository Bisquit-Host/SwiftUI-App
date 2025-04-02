import ScrechKit

struct ServerListFilter: View {
    @Environment(ServerListVM.self) private var vm
    
    private var filterEnabled: Bool {
        vm.filterBySuspended || vm.filterByNotSuspended || !vm.displayedNode.isEmpty
    }
    
    var body: some View {
        Menu {
            if vm.hasSuspendedServers {
                MenuButton("Suspended", icon: vm.filterBySuspended ? "snowflake.circle.fill" : "snowflake") {
                    withAnimation {
                        vm.filterBySuspended.toggle()
                        vm.filterByNotSuspended = false
                    }
                }
                
                MenuButton("Not suspended", icon: vm.filterByNotSuspended ? "snowflake.circle.fill" : "snowflake") {
                    withAnimation {
                        vm.filterByNotSuspended.toggle()
                        vm.filterBySuspended = false
                    }
                }
            }
            
            if vm.hasMultipleNodes {
                ServerListNodeFilter()
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .footnote(.bold)
                .frame(width: 35, height: 35)
                .background(.ultraThinMaterial, in: .circle)
                .symbolVariant(filterEnabled ? .fill : .none)
        }
        .padding(.horizontal, -10)
        .foregroundStyle(.foreground)
    }
}

#Preview {
    ServerListFilter()
        .environment(ServerListVM())
}
