import SwiftUI
import Calagopus

struct BackupContextMenu: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
#if os(tvOS)
        BackupContextMenuControlGroup(backup)
#else
        ControlGroup {
            BackupContextMenuControlGroup(backup)
        }
#endif
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
        }
    }
}

#Preview {
    Menu("Preview") {
        BackupContextMenu(PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
}
