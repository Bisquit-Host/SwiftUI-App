import ScrechKit
import PteroNet

struct Home: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        NavigationSplitView {
            ServerList()
#if os(macOS)
                .background(BackgroundBlur())
#endif
        } detail: {
            if let selectedServer = vm.selectedServer {
                NavigationView {
                    PanelView(selectedServer.id)
                }
                .environment(vm)
            } else {
                Button {
                    vm.fetchServers(settings.adminServerList)
                } label: {
                    Text("Reload")
                }
            }
        }
        .task {
            vm.fetchServers(settings.adminServerList)
        }
    }
}

#Preview {
    Home()
        .environment(ServerListVM())
        .environmentObject(SettingsStorage())
}
