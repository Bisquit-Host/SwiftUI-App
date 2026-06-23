import ScrechKit
import Calagopus

struct BackupDetails: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: CalagopusServerBackup
    
    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }
    
    var body: some View {
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
                
                Button("Restore", systemImage: "arrow.up.bin") {
                    Task {
                        await vm.restoreBackup(backup.uuid, truncate: false)
                    }
                }
                
                Button("Restore Truncate", systemImage: "arrow.up.bin", role: .destructive) {
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
