import ScrechKit
import Calagopus

struct BackupDetailsMenu: View {
    @Environment(BackupVM.self) private var vm
    @Environment(\.dismiss) private var dismiss

    private let backup: CalagopusServerBackup
    private let isSystem: Bool

    init(_ backup: CalagopusServerBackup, isSystem: Bool) {
        self.backup = backup
        self.isSystem = isSystem
    }

    var body: some View {
        let uuid = backup.uuid

        Menu("Actions", systemImage: "ellipsis") {
            Section {
                if !isSystem {
                    AsyncButton(backup.isLocked ? "Unlock" : "Lock", systemImage: backup.isLocked ? "lock.open" : "lock") {
                        await vm.toggleBackupLock(uuid)
                    }

                    BackupMoveMenuView(backup: backup)

                    Button("Rename", systemImage: "pencil") {
                        dismiss()
                        vm.beginRenaming(backup)
                    }
                }

                AsyncButton("Restore", systemImage: "arrow.up.bin") {
                    await vm.restoreBackup(uuid, truncate: false)
                }

                BackupDownloadButton(backup)
            }

            Section {
                AsyncButton("Restore with truncate", systemImage: "arrow.up.bin", role: .destructive) {
                    await vm.restoreBackup(uuid, truncate: true)
                }

                if !isSystem {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        dismiss()

                        Task {
                            await vm.deleteBackup(uuid)
                        }
                    }
                    .disabled(backup.isLocked)
                }
            }
        }
        .disabled(vm.isDeleting(backup))
    }
}
