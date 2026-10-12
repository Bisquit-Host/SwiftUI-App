import ScrechKit
import Calagopus

struct BackupContextMenu: View {
    @Environment(BackupVM.self) private var vm
    
    let backup: CalagopusServerBackup
    var isSystem = false
    
    var body: some View {
        let isDeleting = vm.isDeleting(backup)
        
        ControlGroup {
            BackupContextMenuControlGroup(backup, isSystem: isSystem)
        }
        
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
