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
            HStack {
                Text("Filter")
                    .title3(design: .rounded)
                    .padding(.leading)
                    .padding(.trailing, -10)
                
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .title()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 5)
                    .frame(width: 60, height: 60)
                    .symbolVariant(filterBySuspended ? .fill : .none)
            }
            .semibold()
            .foregroundStyle(.foreground)
            .frame(maxWidth: 160)
            .background(.regularMaterial, in: .rect(cornerRadius: 20))
        }
    }
}

#Preview {
    ServerListFilter(.constant(true))
}
