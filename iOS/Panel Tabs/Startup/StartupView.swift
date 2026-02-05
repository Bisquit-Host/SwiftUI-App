import SwiftUI
import PteroNet

struct StartupView: View {
    @Environment(StartupVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        currentDockerImage = server.dockerImage
    }
    
    @State private var currentDockerImage: String
    @State private var sheetVersionChanger = false
    
    var body: some View {
        List {
            StartupCommand()
            
            Picker("Docker Image", selection: $currentDockerImage) {
                ForEach(vm.sortedDockerImages, id: \.key) { key, value in
                    Text(key)
                        .tag(value)
                }
            }
            .listRowBackground(Color.gray.opacity(0.2))
            
            Section("Version Changer") {
                Button("Open version changer", systemImage: "wand.and.stars") {
                    sheetVersionChanger = true
                }
            }
            .listRowBackground(Color.gray.opacity(0.2))
            
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
        .onChange(of: currentDockerImage) { _, newDockerImage in
            updateDockerImage(newDockerImage)
        }
        .sheet(isPresented: $sheetVersionChanger) {
            VersionChangerSheet(serverUUID: server.uuid)
                .environment(vm)
        }
    }
    
    private func updateDockerImage(_ newImage: String) {
        Task {
            await vm.updateDockerImage(newImage)
        }
    }
}

#Preview {
    StartupView(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(ServerSettingsVM(""))
        .environmentObject(ValueStore())
}
