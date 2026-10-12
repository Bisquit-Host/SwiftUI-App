import ScrechKit
import Calagopus

struct BackupDetailsMenu: View {
    @Environment(BackupVM.self) private var vm
    @Environment(BackupCardVM.self) private var cardVM
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
                AsyncButton("Download", systemImage: "square.and.arrow.down") {
                    await cardVM.downloadBackup(uuid)
                }

                if !isSystem {
                    AsyncButton(backup.isLocked ? "Unlock" : "Lock", systemImage: backup.isLocked ? "lock.open" : "lock") {
                        await vm.toggleBackupLock(uuid)
                    }

                    Button("Rename", systemImage: "pencil") {
                        dismiss()
                        vm.beginRenaming(backup)
                    }
                }

                AsyncButton("Restore", systemImage: "arrow.up.bin") {
                    await vm.restoreBackup(uuid, truncate: false)
                }
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
