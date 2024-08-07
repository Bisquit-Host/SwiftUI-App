import ScrechKit

struct ServerListFilter: View {
    @Environment(ServerListVM.self) private var vm
    
    @Binding private var filterBySuspended: Bool
    
    init(_ filterBySuspended: Binding<Bool>) {
        _filterBySuspended = filterBySuspended
    }
    
    var body: some View {
        Menu {
            MenuButton("Suspended", icon: filterBySuspended ? "snowflake.circle.fill" : "snowflake") {
                withAnimation {
                    filterBySuspended.toggle()
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
        .padding(.leading)
    }
}

#Preview {
    @Previewable @State var filterBySuspended = false
    
    ServerListFilter($filterBySuspended)
        .environment(ServerListVM())
}
