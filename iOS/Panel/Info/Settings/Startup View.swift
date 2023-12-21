import SwiftUI
import PteroNet

struct StartupView: View {
    @Environment(ServerSettingsVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        List(vm.startupVariables, id: \.name) { variable in
            Section {
                StartupCard(server,
                            variable: variable)
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
