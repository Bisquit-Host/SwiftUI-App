import ScrechKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @Environment(UpdateChecker.self) private var updater
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.openURL) private var openUrl
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            ServerListTopbar()
            
            if updater.alertUpdate {
                if let url = URL(string: "https://apps.apple.com/app/bisquit-host/id1639409934") {
                    Button {
                        openUrl(url)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "link")
                            
                            Text("New Update Available")
                        }
                        .title3()
                    }
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .padding(.bottom)
                }
            }
            
            ServerListGrid(vm.filteredServers)
        }
        .navigationBarBackButtonHidden()
        .task {
            await vm.fetchServers(store.adminServerList)
        }
    }
}

#Preview {
    ServerList()
        .environment(ServerListVM())
        .environment(NavState())
        .environment(UpdateChecker())
        .environmentObject(ValueStore())
}
