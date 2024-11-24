import ScrechKit
import PteroNet

struct BackupContextMenu: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        let uuid = backup.uuid
        
        ControlGroup {
            MenuButton("Download", icon: "square.and.arrow.down") {
                vm.downloadBackup(uuid)
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
        
        Section {
            MenuButton("Restore with truncate", role: .destructive, icon: "arrow.up.bin") {
                vm.restoreBackup(uuid, truncate: true)
            }
            
            MenuButton("Delete", role: .destructive, icon: "trash") {
                vm.deleteBackup(uuid)
            }
        }
    }
}

//#Preview {
//    Menu("Preview") {
//        BackupContextMenu(BackupAttributes(uuid: "", name: "", createdAt: "", completedAt: "", isLocked: true, bytes: 64))
//    }
//}
