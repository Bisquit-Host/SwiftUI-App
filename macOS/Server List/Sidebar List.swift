import ScrechKit
import PteroNet

struct Sidebar: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        VStack {
            ServerList()
        }
        .navigationBarBackButtonHidden()
        .task {
            vm.fetchServers(settings.adminServerList)
        }
    }
}

#Preview {
    Sidebar()
        .environment(ServerListVM())
        .environmentObject(SettingsStorage())
}
