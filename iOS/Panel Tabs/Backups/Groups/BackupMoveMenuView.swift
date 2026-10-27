import ScrechKit
import Calagopus

struct BackupMoveMenuView: View {
    @Environment(BackupVM.self) private var vm
    let backup: CalagopusServerBackup

    var body: some View {
        if vm.can("backups.update") && vm.can("backup-groups.read") {
            Menu("Move to group", systemImage: "folder") {
                AsyncButton("No group") {
                    await vm.moveBackup(backup.uuid, to: nil)
                }
                .disabled(backup.backupGroupUuid == nil)

                ForEach(vm.backupGroups) { group in
                    AsyncButton(group.name) {
                        await vm.moveBackup(backup.uuid, to: group.uuid)
                    }
                    .disabled(backup.backupGroupUuid == group.uuid)
                }
            }
            .disabled(vm.isLoadingGroups || vm.groupLoadFailed)
        }
    }
}
