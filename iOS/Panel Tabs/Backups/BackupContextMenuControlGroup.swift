import SwiftUI
import Calagopus

struct BackupContextMenuControlGroup: View {
    @Environment(BackupVM.self) private var vm
    @Environment(BackupCardVM.self) private var cardVM
    
    private let backup: CalagopusServerBackup
    
    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }
    
    var body: some View {
        let uuid = backup.uuid
        let isDeleting = vm.isDeleting(backup)
        
        Button("Download", systemImage: "square.and.arrow.down") {
            Task {
                await cardVM.downloadBackup(uuid)
            }
        }
        .disabled(isDeleting)
        
        if backup.isLocked {
            Button("Unlock", systemImage: "lock.open") {
                Task {
                    await vm.toggleBackupLock(uuid)
                }
            }
            .disabled(isDeleting)
        } else {
            Button("Lock", systemImage: "lock") {
                Task {
                    await vm.toggleBackupLock(uuid)
                }
            }
            .disabled(isDeleting)
        }

        Button("Rename", systemImage: "pencil") {
            vm.beginRenaming(backup)
        }
        .disabled(isDeleting)
        
        Button("Restore", systemImage: "arrow.up.bin") {
            Task {
                await vm.restoreBackup(uuid, truncate: false)
            }
        }
        .disabled(isDeleting)
    }
}
