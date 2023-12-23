import ScrechKit
import PteroNet

struct Home: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
        
    private let gradient = Gradient(colors: [Color(0xf7b948), Color(0xed5547), Color(0x893799)])
    
    var body: some View {
        NavigationSplitView {
            ServerList()
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
        .background {
            ZStack {
#if os(macOS)
                BackgroundBlur()
#endif
                HStack {
                    Rectangle()
                        .fill(gradient)
                        .opacity(0.4)
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
