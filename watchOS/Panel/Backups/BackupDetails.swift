import ScrechKit
import Calagopus

struct BackupDetails: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: CalagopusServerBackup
    
    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }
    
    var body: some View {
        let isDeleting = vm.isDeleting(backup)

        List {
            Section {
                BackupCardContent(backup)
            }
            
            Section {
                Button(backup.isLocked ? "Unlock" : "Lock", systemImage: backup.isLocked ? "lock.open" : "lock") {
                    Task {
                        await vm.toggleBackupLock(backup.uuid)
                    }
                }
                .disabled(isDeleting)
                
                Button("Restore", systemImage: "arrow.up.bin") {
                    Task {
                        await vm.restoreBackup(backup.uuid, truncate: false)
                    }
                }
                .disabled(isDeleting)
                
                Button("Restore Truncate", systemImage: "arrow.up.bin", role: .destructive) {
                    Task {
                        await vm.restoreBackup(backup.uuid, truncate: true)
                    }
                }
                .disabled(isDeleting)
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    Task {
                        await vm.deleteBackup(backup.uuid)
                    }
                }
                .disabled(backup.isLocked || isDeleting)
            }
        }
        .navigationTitle("Backup")
    }
}

#Preview {
    NavigationStack {
        BackupDetails(PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
