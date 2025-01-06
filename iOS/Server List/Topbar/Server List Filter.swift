import ScrechKit

struct ServerListFilter: View {
    @Environment(ServerListVM.self) private var vm
    
    @Binding private var filterBySuspended: Bool
    
    init(_ filterBySuspended: Binding<Bool>) {
        _filterBySuspended = filterBySuspended
    }
    
    private var hasSuspendedServers: Bool {
        vm.servers.filter(\.isSuspended).count > 0
    }
    
    var body: some View {
        Menu {
            if hasSuspendedServers {
                MenuButton("Suspended", icon: filterBySuspended ? "snowflake.circle.fill" : "snowflake") {
                    withAnimation {
                        filterBySuspended.toggle()
                    }
                }
            }
            
            ServerListNodeFilter()
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .title(.semibold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 5)
                .frame(width: 60, height: 60)
                .symbolVariant(filterBySuspended ? .fill : .none)
                .background(.ultraThinMaterial, in: .circle)
        }
        .hoverEffect(.lift)
        .padding(.trailing)
    }
}

#Preview {
    @Previewable @State var filterBySuspended = false
    
    ServerListFilter($filterBySuspended)
        .environment(ServerListVM())
}
