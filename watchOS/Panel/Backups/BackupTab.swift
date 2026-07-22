import SwiftUI
import Calagopus

struct BackupTab: View {
    @Environment(BackupVM.self) private var vm
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            if vm.backups.isEmpty {
                ContentUnavailableView(
                    "No backups yet",
                    systemImage: "doc.zipper",
                    description: Text("Use the button in the top right corner to create one")
                )
            }
            
            Section {
                ForEach(vm.backups) {
                    BackupCard($0)
                }
            } header: {
                Text("\(vm.backups.count) / \(server.featureLimits.backups)")
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
            
            Section {
                Button("Create Backup", systemImage: "plus", action: showCreateBackupAlert)
                    .disabled(vm.backups.count >= server.featureLimits.backups)
            }
        }
        .navigationTitle("Backups")
        .task {
            await vm.fetchBackups()
            await vm.fetchBackupGroupsIfNeeded()
        }
        .refreshable {
            await vm.fetchBackups()
        }
        .alert("Backup name", isPresented: $vm.alertCreateBackup) {
            TextField("Backup at \(vm.dateAndTime)", text: $vm.textCreateBackup)
                .textInputAutocapitalization(.never)
            
            Button("Create", role: .confirm, action: createBackup)
            Button("Cancel", role: .cancel) {
                vm.textCreateBackup = ""
            }
        }
        .alert("Rename backup", isPresented: $vm.alertRenameBackup) {
            TextField("Backup name", text: $vm.textRenameBackup)
                .textInputAutocapitalization(.never)
                .limitInputLength($vm.textRenameBackup, length: 255)

            Button("Save", role: .confirm, action: renameBackup)
                .disabled(vm.textRenameBackup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func showCreateBackupAlert() {
        vm.alertCreateBackup = true
    }
    
    private func createBackup() {
        Task {
            await vm.createBackup()
        }
    }

    private func renameBackup() {
        Task {
            await vm.renameBackup()
        }
    }
}

#Preview {
    NavigationStack {
        BackupTab(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
