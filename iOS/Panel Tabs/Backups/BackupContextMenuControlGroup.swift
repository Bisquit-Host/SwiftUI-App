import ScrechKit
import Calagopus

struct BackupContextMenuControlGroup: View {
    @Environment(BackupVM.self) private var vm
    @Environment(BackupCardVM.self) private var cardVM
    
    private let backup: CalagopusServerBackup
    private let isSystem: Bool
    
    init(_ backup: CalagopusServerBackup, isSystem: Bool = false) {
        self.backup = backup
        self.isSystem = isSystem
    }
    
    var body: some View {
        let uuid = backup.uuid
        let isDeleting = vm.isDeleting(backup)
        
        AsyncButton("Download", systemImage: "square.and.arrow.down") {
            await cardVM.downloadBackup(uuid)
        }
        .disabled(isDeleting)
        
        if !isSystem {
            if backup.isLocked {
                AsyncButton("Unlock", systemImage: "lock.open") {
                    await vm.toggleBackupLock(uuid)
                }
                .disabled(isDeleting)
            } else {
                AsyncButton("Lock", systemImage: "lock") {
                    await vm.toggleBackupLock(uuid)
                }
                .disabled(isDeleting)
            }

            AsyncButton("Rename", systemImage: "pencil") {
                vm.beginRenaming(backup)
            }
            .disabled(isDeleting)
        }
        
        AsyncButton("Restore", systemImage: "arrow.up.bin") {
            await vm.restoreBackup(uuid, truncate: false)
        }
        .disabled(isDeleting)
    }
}
