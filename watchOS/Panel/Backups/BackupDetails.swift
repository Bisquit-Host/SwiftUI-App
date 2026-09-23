import ScrechKit
import Calagopus

struct BackupDetails: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: CalagopusServerBackup
    
    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }
    
    var body: some View {
        let isDeleting = vm.isDeleting(backup)
        
        List {
            Section {
                BackupCardContent(backup)
            }
            
            Section {
                Button("Rename", systemImage: "pencil") {
                    vm.beginRenaming(backup)
                }
                .disabled(isDeleting)
                
                AsyncButton(backup.isLocked ? "Unlock" : "Lock", systemImage: backup.isLocked ? "lock.open" : "lock") {
                    await vm.toggleBackupLock(backup.uuid)
                }
                .disabled(isDeleting)
                
                AsyncButton("Restore", systemImage: "arrow.up.bin") {
                    await vm.restoreBackup(backup.uuid, truncate: false)
                }
                .disabled(isDeleting)
                
                AsyncButton("Restore Truncate", systemImage: "arrow.up.bin", role: .destructive) {
                    await vm.restoreBackup(backup.uuid, truncate: true)
                }
                .disabled(isDeleting)
                
                AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                    await vm.deleteBackup(backup.uuid)
                }
                .disabled(backup.isLocked || isDeleting)
            }
        }
        .navigationTitle("Backup")
    }
}

#Preview {
    NavigationStack {
        BackupDetails(PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
