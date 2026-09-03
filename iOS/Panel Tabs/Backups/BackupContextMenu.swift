import SwiftUI
import Calagopus

struct BackupContextMenu: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: CalagopusServerBackup
    
    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }
    
    var body: some View {
        let isDeleting = vm.isDeleting(backup)

        ControlGroup {
            BackupContextMenuControlGroup(backup)
        }
        Section {
            Button("Restore with truncate", systemImage: "arrow.up.bin", role: .destructive) {
                Task {
                    await vm.restoreBackup(backup.uuid, truncate: true)
                }
            }
            
            Button("Delete", systemImage: "trash", role: .destructive) {
                Task {
                    await vm.deleteBackup(backup.uuid)
                }
            }
            .disabled(backup.isLocked)
        }
        .disabled(isDeleting)
    }
}

#Preview {
    Menu("Preview") {
        BackupContextMenu(PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
}
