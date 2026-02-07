import ScrechKit
import PteroNet

struct ServerSettingsView: View {
    private var vm: ServerSettingsVM
    @Environment(PanelVM.self) private var panelVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        vm = ServerSettingsVM(server.id)
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
                        save()
                    }
                    .animation(.default, value: vm.serverName + vm.serverDescription)
                }
            }
            
            Section("SFTP") {
                SftpDetails(server.sftp)
                    .environment(vm)
            }
            
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
        }
        .navigationTitle("Server Settings")
#if os(iOS) || os(macOS) || os(visionOS)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .task {
            await vm.accountDetails()
            vm.serverName = server.name
            vm.serverDescription = server.description
        }
        .onDisappear {
            Task {
                await panelVM.fetchServerDetails()
            }
        }
        .alert("Reinstall Server", isPresented: $alertReinstall) {
            Button("Reinstall", role: .destructive, action: reinstall)
        } message: {
            Text("Reinstalling your server will stop it, and then re-run the installation script that initially set it. Some files may be deleted or modified during this process, please back up your data before continuing")
        }
    }
    
    private func save() {
        Task {
            await vm.serverRename()
        }
    }
    
    private func reinstall() {
        Task {
            await PteroNet.reinstallServer(server.id) {
                SystemAlert.reinstalled()
            }
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
