import ScrechKit
import Calagopus

struct ServerSettingsView: View {
    private var vm: ServerSettingsVM
    @Environment(PanelVM.self) private var panelVM
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
        vm = ServerSettingsVM(server.id)
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section("Name & description") {
                TextField("Server name", text: $vm.serverName)
                    .autocorrectionDisabled()
                    .limitInputLength($vm.serverName, length: 191)
                
                TextField("Server description", text: $vm.serverDescription)
                
                if vm.serverName != server.name || vm.serverDescription != (server.description ?? "") {
                    Button("Save", action: save)
                        .animation(.default, value: vm.serverName + vm.serverDescription)
                }
            }
            
            Section("SFTP") {
                SFTPDetails(server)
                    .environment(vm)
            }
            
            ServerSettingsAutoStartSection()
            ServerSettingsAutoKillSection()
            ServerSettingsTimezoneSection()
            ServerSettingsReinstall(server.id)
        }
        .environment(vm)
        .navigationTitle("Server Settings")
#if os(iOS) || os(macOS) || os(visionOS)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .task {
            await vm.accountDetails()
            await vm.fetchCalagopusSettings()
            vm.serverName = server.name
            vm.serverDescription = server.description ?? ""
        }
        .onDisappear {
            Task {
                await panelVM.fetchServerDetails()
            }
        }
    }
    
    private func save() {
        Task {
            await vm.serverRename()
        }
    }
}

#Preview {
    NavigationStack {
        ServerSettingsView(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(PanelVM(""))
}
