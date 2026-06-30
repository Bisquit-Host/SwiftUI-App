import SwiftUI
import Calagopus

struct StartupTab: View {
    @Environment(StartupVM.self) private var vm
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        List {
            StartupCommand()
            StartupDockerImagePicker(server.image)
            
            ForEach(vm.startupVariables) {
                StartupCard(server, variable: $0)
                    .listRowBackground(Color.gray.opacity(0.2))
            }
        }
        .scrollIndicators(.never)
        .frame(maxWidth: 500)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
        .refreshableTask {
            await vm.fetchStartupVariables()
        }
        .environment(vm)
    }
}

#Preview {
    StartupTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(ServerSettingsVM(""))
}
