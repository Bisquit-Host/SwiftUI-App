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
            BackupList(server)

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
        .animation(.default, value: vm.backups.count)
        .scrollIndicators(.never)
        .overlay {
            if vm.isLoadingBackups && vm.backups.isEmpty {
                ProgressView()
            } else if vm.hasFinishedLoadingBackups && vm.backups.isEmpty {
                BackupListEmptyState()
            }
        }
#if !os(tvOS)
        .frame(maxWidth: 500)
#endif
        .refreshableTask {
            await vm.fetchBackups()
        }
        .task {
            await vm.fetchBackupGroupsIfNeeded()
        }
        .alert("Backup name", isPresented: $vm.alertCreateBackup) {
            TextField("Backup at \(vm.dateAndTime)", text: $vm.textCreateBackup)
                .autocorrectionDisabled()
                .limitInputLength($vm.textCreateBackup, length: 191)
            
            Button("Create", role: .confirm, action: createBackup)
            Button("Cancel", role: .cancel) {}
        }
        .alert("Rename backup", isPresented: $vm.alertRenameBackup) {
            TextField("Backup name", text: $vm.textRenameBackup)
                .autocorrectionDisabled()
                .limitInputLength($vm.textRenameBackup, length: 255)

            Button("Save", role: .confirm, action: renameBackup)
                .disabled(vm.textRenameBackup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("Cancel", role: .cancel) {}
        }
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
    BackupTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(BackupVM(""))
}
