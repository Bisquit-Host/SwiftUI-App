import ScrechKit
import Calagopus

struct BackupContextMenu: View {
    @Environment(BackupVM.self) private var vm
    
    let backup: CalagopusServerBackup
    var isSystem = false
    
    var body: some View {
        let isDeleting = vm.isDeleting(backup)
        
        Section {
            if !isSystem {
                AsyncButton(backup.isLocked ? "Unlock" : "Lock", systemImage: backup.isLocked ? "lock.open" : "lock") {
                    await vm.toggleBackupLock(backup.uuid)
                }
                
                BackupMoveMenuView(backup: backup)

                Button("Rename", systemImage: "pencil") {
                    vm.beginRenaming(backup)
                }
            }
            
            AsyncButton("Restore", systemImage: "arrow.up.bin") {
                await vm.restoreBackup(backup.uuid, truncate: false)
            }
            
            BackupDownloadButton(backup)
        }
        .disabled(isDeleting)
        
        Section {
            AsyncButton("Restore with truncate", systemImage: "arrow.up.bin", role: .destructive) {
                await vm.restoreBackup(backup.uuid, truncate: true)
            }
            
            if !isSystem {
                AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                    await vm.deleteBackup(backup.uuid)
                }
                .disabled(backup.isLocked)
            }
        }
        .disabled(isDeleting)
    }
}

#Preview {
    Menu("Preview") {
        BackupContextMenu(backup: PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
}
