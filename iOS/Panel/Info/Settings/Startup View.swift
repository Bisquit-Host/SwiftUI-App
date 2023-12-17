import SwiftUI
import PteroNet

struct StartupView: View {
    @Environment(ServerSettingsVM.self) private var vm
    
    private let server: ServerListAttributes
    
    init(_ server: ServerListAttributes) {
        self.server = server
    }
    
    var body: some View {
        List(vm.startupVariables, id: \.attributes.name) { variable in
            Section {
                StartupCard(server, variable: variable.attributes)
            }
        }
        .navigationTitle("Startup")
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
    }
}

#Preview {
    StartupView(
        sampleJSON(.serverListAttributes)
    )
    .environment(ServerSettingsVM(""))
}
