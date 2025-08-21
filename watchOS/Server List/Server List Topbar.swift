import ScrechKit

struct ServerListTopbar: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @State private var isRotating = false
    
    var body: some View {
        HStack {
            SFButton("arrow.triangle.2.circlepath") {
                fetch()
            }
            
            Button {
                navState.navigate(.toSettings)
            } label: {
                Image(systemName: "gear")
                    .secondary()
                    .rotate(isRotating ? 360 : 0)
                    .animation(
                        .linear(duration: 60).repeatForever(autoreverses: false),
                        value: isRotating
                    )
            }
        }
        .title2(.bold)
        .buttonStyle(.glass)
        .task {
            isRotating = true
        }
    }
    
    private func fetch() {
        Task {
            await vm.fetchServers(store.adminServerList)
        }
    }
}

#Preview {
    ServerListTopbar()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
