import ScrechKit
import PteroNet

struct BackupContextMenu: View {
    @Environment(DataTabVM.self) private var vm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        @Bindable var binding = vm
        let uuid = backup.uuid
        
        MenuButton("Download", icon: "square.and.arrow.down") {
            vm.downloadBackup(uuid)
        }
        
        if backup.isLocked {
            MenuButton("Unlock", role: .destructive, icon: "lock.open") {
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
        
        Section {
            MenuButton("Restore with truncate", role: .destructive, icon: "arrow.up.bin") {
                vm.restoreBackup(uuid, truncate: true)
            }
            
            MenuButton("Delete", role: .destructive, icon: "trash") {
                vm.deleteData(uuid, endpoint: .backups)
            }
        }
    }
}
