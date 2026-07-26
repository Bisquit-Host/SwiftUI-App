import SwiftUI
import Calagopus

struct BackupList: View {
    @Environment(BackupVM.self) private var vm
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if vm.backups.isEmpty {
                    ContentUnavailableView(
                        "No backups yet",
                        systemImage: "doc.zipper",
                        description: Text("Use the button in the top right corner to create one")
                    )
                } else {
                    ForEach(vm.backups) {
                        BackupCard($0)
                    }
                }
            }
            
            Text("\(vm.backups.count) / \(server.featureLimits.backups) backups used")

            if !vm.backupGroups.isEmpty {
                Picker("Backup group", selection: $vm.selectedBackupGroupID) {
                    Text("No group")
                        .tag(nil as String?)

                    ForEach(vm.backupGroups) {
                        Text($0.name)
                            .tag($0.uuid as String?)
                    }
                }
            }
            
            Button("Create backup") {
                vm.alertCreateBackup = true
            }
            .disabled(vm.backups.count >= server.featureLimits.backups)
        }
        .navigationTitle("Backups")
        .scrollIndicators(.never)
        .padding()
        .task {
            await vm.fetchBackups()
            await vm.fetchBackupGroupsIfNeeded()
        }
        .alert("Backup name", isPresented: $vm.alertCreateBackup) {
            TextField("Backup at \(vm.dateAndTime)", text: $vm.textCreateBackup)
                .autocorrectionDisabled()
                .limitInputLength($vm.textCreateBackup, length: 191)
            
            Button("Create", role: .confirm, action: create)
            Button("Cancel", role: .cancel) {}
        }
        .alert("Rename backup", isPresented: $vm.alertRenameBackup) {
            TextField("Backup name", text: $vm.textRenameBackup)
                .autocorrectionDisabled()
                .limitInputLength($vm.textRenameBackup, length: 255)

            Button("Save", role: .confirm, action: rename)
                .disabled(vm.textRenameBackup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func create() {
        Task {
            await vm.createBackup()
        }
    }

    private func rename() {
        Task {
            await vm.renameBackup()
        }
    }
}

#Preview {
    NavigationStack {
        BackupList(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
