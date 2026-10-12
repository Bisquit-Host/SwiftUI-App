import ScrechKit
import Calagopus

struct BackupDetailsStatus: View {
    @Environment(BackupVM.self) private var vm

    private let backup: CalagopusServerBackup

    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }

    var body: some View {
        HStack(spacing: 4) {
            if vm.isDeleting(backup) {
                ProgressView()
                    .controlSize(.small)

                Text("Deleting…")
                    .secondary()

            } else if backup.deletionStatus == .failed {
                Text("Deletion failed")
                    .foregroundStyle(.red)

            } else if backup.completed == nil {
                ProgressView()
                    .controlSize(.small)

                Text("In progress")
                    .secondary()

            } else if backup.isSuccessful {
                Text("Completed")
                    .foregroundStyle(.green)

            } else {
                Text("Failed")
                    .foregroundStyle(.red)
            }

            if backup.isLocked {
                Text("Locked")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.orange)
            }
        }
    }
}

#Preview {
    BackupDetailsStatus(PreviewProp.backupAttributes)
        .darkSchemePreferred()
        .environment(BackupVM(""))
}
