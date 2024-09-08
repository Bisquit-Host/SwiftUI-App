import SwiftUI
import PteroNet

struct StartupView: View {
    @Environment(StartupVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        currentDockerImage = server.dockerImage
    }
    
    @State private var showRawCommand = false
    @State private var currentDockerImage: String
    
    var body: some View {
        List {
            Section("Startup Command") {
                Text(showRawCommand ? vm.rawStartupCommand : vm.startupCommand)
                    .textSelection(.enabled)
                    .caption2(design: .monospaced)
                    .animation(.default, value: showRawCommand)
                
                Toggle("Raw", isOn: $showRawCommand)
            }
            
            Picker("Docker Image", selection: $currentDockerImage) {
                ForEach(vm.sortedDockerImages, id: \.key) { key, value in
                    Text(key)
                        .tag(value)
                }
            }
            
            ForEach(vm.startupVariables, id: \.name) { variable in
                StartupCard(server, variable: variable)
            }
        }
        .scrollIndicators(.never)
        .refreshableTask {
            vm.fetchStartupVariables()
        }
        .onChange(of: currentDockerImage) { _, newDockerImage in
            vm.updateDockerImage(newDockerImage)
        }
    }
}

#Preview {
    StartupView(
        sampleJSON(.serverListAttributes)
    )
    .environment(ServerSettingsVM(""))
}
