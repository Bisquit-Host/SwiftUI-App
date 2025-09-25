import ScrechKit
import PteroNet

struct Home: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let gradient = Gradient(colors: [
        Color(0xf7b948),
        Color(0xed5547),
        Color(0x893799)
    ])
    
    var body: some View {
        NavigationSplitView {
            ServerList()
        } detail: {
            if let selectedServer = vm.selectedServer {
                PanelView(selectedServer)
                    .environment(vm)
            }
        }
        .background {
            ZStack {
#if os(macOS)
                BackgroundBlur()
#endif
                HStack {
                    Rectangle()
                        .fill(gradient)
                        .opacity(0.3)
                }
            }
            .ignoresSafeArea()
        }
        .task {
            await vm.fetchServers(store.adminServerList)
        }
    }
}

#Preview {
    Home()
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environmentObject(ValueStore())
}
