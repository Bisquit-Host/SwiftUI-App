import SwiftUI

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        @Bindable var binding = vm
        
        List {
            ForEach(vm.filteredServers, id: \.id) { server in
                ServerCardParent(server)
            }
        }
        .padding(.horizontal, 4)        
        .navigationTitle("Server List")
        .navigationBarBackButtonHidden()
        .toolbar {
            ServerListToolbar {
                vm.fetchServers(settings.adminServerList)
            }
        }
        //        .ornament(attachmentAnchor: .scene(.top)) {
        //            ServerListOrnament()
        //                .environment(binding)
        //        }
        //        .sheet($binding.sheetSettings) {
        //            AppSettings()
        //        }
        .refreshableTask {
            vm.fetchServers(settings.adminServerList)
        }
    }
}

#Preview {
    ServerList()
        .padding()
        .glassBackgroundEffect()
        .environment(ServerListVM())
        .environmentObject(SettingsStorage())
}
