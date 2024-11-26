import ScrechKit
import PteroNet

struct BackupContextMenu: View {
    @Environment(BackupVM.self) private var vm
    @Environment(BackupCardVM.self) private var cardVm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        let uuid = backup.uuid
        
#if os(tvOS)
        BackupContextMenuControlGroup(backup)
#else
        ControlGroup {
            BackupContextMenuControlGroup(backup)
        }
#endif
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
