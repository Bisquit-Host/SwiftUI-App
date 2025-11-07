import SwiftUI
import PteroNet

struct BackupContextMenuControlGroup: View {
    @Environment(BackupVM.self) private var vm
    @Environment(BackupCardVM.self) private var cardVM
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        let uuid = backup.uuid
        
        Button("Download", systemImage: "square.and.arrow.down") {
            Task {
                await cardVM.downloadBackup(uuid)
            }
        }
        
        if backup.isLocked {
            Button("Unlock", systemImage: "lock.open") {
                Task {
                    await vm.toggleBackupLock(uuid)
                }
            }
        } else {
            Button("Lock", systemImage: "lock") {
                Task {
                    await vm.toggleBackupLock(uuid)
                }
            }
        }
        
        Button("Restore", systemImage: "arrow.up.bin") {
            Task {
                await vm.restoreBackup(uuid, truncate: false)
            }
        }
    }
}
