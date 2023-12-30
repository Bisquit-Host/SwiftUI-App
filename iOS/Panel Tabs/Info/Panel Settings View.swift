import ScrechKit
import PteroNet

struct PanelSettingsView: View {
    private var vm: ServerSettingsVM
    @Environment(PanelVM.self) private var panelVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = ServerSettingsVM(server.id)
    }
    
    @State private var alertReinstall = false
    
    var body: some View {
        @Bindable var binding = vm
        
        List {
            Section("Name & description") {
                TextField("Server name", text: $binding.serverName)
                    .autocorrectionDisabled()
                
                TextField("Server description", text: $binding.serverDescription)
                
                if vm.serverName != server.name || vm.serverDescription != server.description {
                    Button("Save") {
                        vm.serverRename()
                    }
                }
            }
            
            Section("SFTP") {
                SftpDetails(server.sftp)
                    .environment(vm)
            }
            
            Section {
                ListButton("Reinstall", actionIcon: "arrow.triangle.2.circlepath", color: .red) {
                    alertReinstall = true
                }
            }
        }
        .task {
            vm.accountDetails()
            vm.serverName = server.name
            vm.serverDescription = server.description
        }
        .onDisappear {
            panelVM.fetchServerDetails()
        }
        .alert("Reinstall Server", isPresented: $alertReinstall) {
            Button("Reinstall", role: .destructive) {
                PteroNet.reinstallServer(server.id)
            }
        } message: {
            Text("Reinstalling your server will stop it, and then re-run the installation script that initially set it. Some files may be deleted or modified during this process, please back up your data before continuing")
        }
    }
}

#Preview {
    PanelSettingsView(
        sampleJSON(.serverListAttributes)
    )
    .environment(PanelVM(""))
}
