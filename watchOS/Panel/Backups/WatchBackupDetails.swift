import ScrechKit
import PteroNet

struct WatchBackupDetails: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        List {
            Section {
                WatchBackupCardContent(backup)
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
        WatchBackupDetails(PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
