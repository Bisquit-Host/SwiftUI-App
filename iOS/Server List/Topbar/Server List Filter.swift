import ScrechKit

struct ServerListFilter: View {
    @Environment(ServerListVM.self) private var vm
    
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
                .title(.semibold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 5)
                .frame(width: 60, height: 60)
                .symbolVariant(vm.filterBySuspended || vm.filterByNotSuspended ? .fill : .none)
                .background(.ultraThinMaterial, in: .circle)
        }
        .hoverEffect(.lift)
        .padding(.trailing)
    }
}

#Preview {
    ServerListFilter()
        .environment(ServerListVM())
}
