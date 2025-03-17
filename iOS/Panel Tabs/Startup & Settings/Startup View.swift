import ScrechKit
import PteroNet

struct StartupView: View {
    @Environment(StartupVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        currentDockerImage = server.dockerImage
    }
    
    @State private var currentDockerImage: String
    
    var body: some View {
        List {
            Section {
                Text(store.rawStartupCommand ? vm.rawStartupCommand : vm.startupCommand)
                    .caption2()
                    .monospaced()
                    .textSelection(.enabled)
                    .animation(.default, value: store.rawStartupCommand)
                
                if vm.rawStartupCommand != vm.startupCommand {
                    Toggle("Raw", isOn: $store.rawStartupCommand)
                }
            } header: {
                HStack {
                    Text("Startup Command")
                    
                    Spacer()
                    
                    SFButton("document.on.document") {
                        UIPasteboard.general.string = store.rawStartupCommand ? vm.rawStartupCommand : vm.startupCommand
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
        .toolbarBackground(.visible, for: .tabBar)
        .background {
            Image(.darkBackgroundInfo)
                .resizable()
                .blur(radius: 55, opaque: true)
        }
        .scrollContentBackground(.hidden)
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
        .environmentObject(ValueStore())
}
