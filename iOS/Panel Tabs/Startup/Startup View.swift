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
    
    private var command: String {
        store.rawStartupCommand ? vm.rawStartupCommand : vm.startupCommand
    }
    
    var body: some View {
        List {
            Section {
                Text(command)
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
                        UIPasteboard.general.string = command
                        SystemAlert.copied()
                    }
                    .foregroundStyle(.foreground)
                }
            }
            .listRowBackground(Color.gray.opacity(0.2))
            
            Picker("Docker Image", selection: $currentDockerImage) {
                ForEach(vm.sortedDockerImages, id: \.key) { key, value in
                    Text(key)
                        .tag(value)
                }
            }
            .listRowBackground(Color.gray.opacity(0.2))
            
            ForEach(vm.startupVariables) { variable in
                StartupCard(server, variable: variable)
                    .listRowBackground(Color.gray.opacity(0.2))
            }
        }
        .navigationTitle("Startup")
        .navigationSubtitle("Goida")
        .scrollIndicators(.never)
        .frame(maxWidth: 500)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
        .refreshableTask {
            await vm.fetchStartupVariables()
        }
        .onChange(of: currentDockerImage) { _, newDockerImage in
            updateDockerImage(newDockerImage)
        }
    }
    
    private func updateDockerImage(_ newImage: String) {
        Task {
            await vm.updateDockerImage(newImage)
        }
    }
}

#Preview {
    StartupView(sampleJSON(.serverListAttributes))
        .environment(ServerSettingsVM(""))
        .environmentObject(ValueStore())
}
