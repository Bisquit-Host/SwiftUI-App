import SwiftUI
import Calagopus

struct BackupGroupSectionView: View {
    @Environment(BackupVM.self) private var vm
    let serverID: String
    let group: CalagopusServerBackupGroup

    var body: some View {
        Section {
            ForEach(vm.backups(in: group.uuid)) {
                BackupCard(serverID, $0)
                    .focusable()
            }

            if group.totalBackups == 0 {
                Text("No backups yet")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text(group.name)
        }
    }
}
