import SwiftUI

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        @Bindable var binding = vm
        
        ScrollView {
            LazyVGrid(
                columns: [ GridItem(.adaptive(minimum: 180)) ]
                //columns: [ GridItem(.adaptive(minimum: settings.designCode == 0 ? 180 : 360)) ]
            ) {
                ForEach(vm.servers, id: \.attributes.id) { server in
                    ServerCardParent(server.attributes)
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Server List")
        .navigationBarBackButtonHidden()
        .toolbar {
            ServerListToolbar {
                vm.fetchServers(settings.adminServerList)
            }
        }
        .ornament(attachmentAnchor: .scene(.top)) {
            ServerListOrnament()
                .environment(binding)
        }
        //        .sheet($binding.sheetSettings) {
        //            AppSettings()
        //        }
        .task {
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
