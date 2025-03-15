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
        @Bindable var vm = vm
        
        List {
            Section("Name & description") {
                TextField("Server name", text: $vm.serverName)
                    .autocorrectionDisabled()
                    .limitInputLength($vm.serverName, length: 191)
                
                TextField("Server description", text: $vm.serverDescription)
                
                if vm.serverName != server.name || vm.serverDescription != server.description {
                    Button("Save") {
                        vm.serverRename()
                    }
                }
            }
            .transparentSection()
            
            Section("SFTP") {
                SftpDetails(server.sftp)
                    .environment(vm)
            }
            .transparentSection()
            
            Section {
                Button(role: .destructive) {
                    alertReinstall = true
                } label: {
                    HStack {
                        Text("Reinstall")
                        
                        Spacer()
                        
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
            .transparentSection()
        }
        .navigationTitle("Server Settings")
        .toolbarTitleDisplayMode(.inline)
        .transparentList()
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
                PteroNet.reinstallServer(server.id) {
                    SystemAlert.reinstalled()
                }
            }
        } message: {
            Text("Reinstalling your server will stop it, and then re-run the installation script that initially set it. Some files may be deleted or modified during this process, please back up your data before continuing")
        }
    }
}

#Preview {
    PanelSettingsView(sampleJSON(.serverListAttributes))
        .environment(PanelVM(""))
}
