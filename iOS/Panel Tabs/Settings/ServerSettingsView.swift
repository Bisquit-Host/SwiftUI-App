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
            Section("Server ID") {
                HStack {
                    Text(server.id)
                        .textSelection(.enabled)
                    
                    Spacer()
                    
                    Button("Copy server ID", systemImage: "doc.on.doc") {
                        Pasteboard.copy(server.id)
                        SystemAlert.copied()
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .secondary()
                }
            }
            
            Section("Name & description") {
                TextField("Server name", text: $vm.serverName)
                    .autocorrectionDisabled()
                    .limitInputLength($vm.serverName, length: 191)
                    .submitLabel(.done)
                    .onSubmit(save)
                
                TextField("Server description", text: $vm.serverDescription)
                    .submitLabel(.done)
                    .onSubmit(save)
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
        .panelContentMargins()
        .environment(vm)
        .panelNavigationTitle("Settings")
        .scrollIndicators(.never)
        .refreshableTask {
            await vm.accountDetails()
            await vm.fetchSFTPPassword()
            await vm.fetchCalagopusSettings()
            vm.setServerDetails(name: server.name, description: server.description ?? "")
        }
        .onDisappear {
            Task {
                await vm.renameServer()
                await panelVM.fetchServerDetails()
            }
        }
    }
    
    private func save() {
        Task {
            await vm.renameServer()
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
