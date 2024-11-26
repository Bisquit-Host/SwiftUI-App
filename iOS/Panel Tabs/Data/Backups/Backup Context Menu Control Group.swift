import ScrechKit
import PteroNet

struct BackupContextMenuControlGroup: View {
    @Environment(BackupVM.self) private var vm
    @Environment(BackupCardVM.self) private var cardVm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        let uuid = backup.uuid
        
        MenuButton("Download", icon: "square.and.arrow.down") {
            cardVm.downloadBackup(uuid)
        }
        
        if backup.isLocked {
            MenuButton("Unlock", icon: "lock.open") {
                vm.lockBackup(uuid)
            }
        } else {
            MenuButton("Lock", icon: "lock") {
                vm.lockBackup(uuid)
            }
        }
        
        MenuButton("Restore", icon: "arrow.up.bin") {
            vm.restoreBackup(uuid, truncate: false)
        }
    }
}
