import ScrechKit
import Calagopus

struct BackupTab: View {
    @Environment(BackupVM.self) private var vm
    @State private var showGroups = false
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            if vm.can("backup-groups.read") || vm.can("backup-groups.create") {
                Section {
                    Button("Manage groups", systemImage: "folder") {
                        showGroups = true
                    }
                }
            }

            BackupList(server)

            if vm.isLoadingBackups && vm.backups.isEmpty {
                ProgressView()
            }

            if vm.hasFinishedLoadingBackups && vm.backups.isEmpty && vm.systemBackups.isEmpty && vm.backupGroups.isEmpty {
                BackupListEmptyState()
            }
            
            if !vm.backupGroups.isEmpty {
                Section("New backups") {
                    Picker("Backup group", selection: $vm.selectedBackupGroupID) {
                        Text("No group")
                            .tag(nil as String?)
                        
                        ForEach(vm.backupGroups) {
                            Text($0.name)
                                .tag($0.uuid as String?)
                        }
                    }
                }
            }
        }
        .panelContentMargins()
        .animation(.default, value: vm.backups.count)
        .scrollIndicators(.never)
        .refreshableTask {
            vm.configure(server)
            await vm.refresh()
        }
        .sheet(isPresented: $showGroups) {
            NavigationStack {
                BackupGroupsView()
            }
            .environment(vm)
        }
        .alert("Backup name", isPresented: $vm.alertCreateBackup) {
            TextField("Backup at \(vm.dateAndTime)", text: $vm.textCreateBackup)
                .autocorrectionDisabled()
                .limitInputLength($vm.textCreateBackup, length: 191)
            
            AsyncButton("Create", role: .confirm, action: vm.createBackup)
            Button("Cancel", role: .cancel) {}
        }
        .alert("Rename backup", isPresented: $vm.alertRenameBackup) {
            TextField("Backup name", text: $vm.textRenameBackup)
                .autocorrectionDisabled()
                .limitInputLength($vm.textRenameBackup, length: 255)
            
            AsyncButton("Save", role: .confirm, action: vm.renameBackup)
                .disabled(vm.textRenameBackup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    BackupTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(BackupVM(""))
}
