import ScrechKit
import PteroNet

struct StartupView: View {
    @Environment(StartupVM.self) private var vm
    @EnvironmentObject private var storage: ValueStorage
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        currentDockerImage = server.dockerImage
    }
    
    @State private var currentDockerImage: String
    
    var body: some View {
        List {
            Section {
                Text(storage.rawStartupCommand ? vm.rawStartupCommand : vm.startupCommand)
                    .caption2()
                    .monospaced()
                    .textSelection(.enabled)
                    .animation(.default, value: storage.rawStartupCommand)
                
                if vm.rawStartupCommand != vm.startupCommand {
                    Toggle("Raw", isOn: $storage.rawStartupCommand)
                }
            } header: {
                HStack {
                    Text("Startup Command")
                    
                    Spacer()
                    
                    SFButton("document.on.document") {
                        UIPasteboard.general.string = storage.rawStartupCommand ? vm.rawStartupCommand : vm.startupCommand
                        SystemAlert.copied()
                    }
                }
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
        .frame(maxWidth: 500)
        .refreshableTask {
            vm.fetchStartupVariables()
        }
        .onChange(of: currentDockerImage) { _, newDockerImage in
            vm.updateDockerImage(newDockerImage)
        }
    }
}

#Preview {
    StartupView(sampleJSON(.serverListAttributes))
        .environment(ServerSettingsVM(""))
        .environmentObject(ValueStorage())
}
