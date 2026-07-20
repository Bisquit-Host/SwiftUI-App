import ScrechKit
import Calagopus

struct BackupCardContent: View {
    @Environment(BackupVM.self) private var vm

    private let backup: CalagopusServerBackup
    
    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }
    
    var body: some View {
        let isDeleting = vm.isDeleting(backup)

        VStack(alignment: .leading) {
            HStack {
                if backup.deletionStatus == .failed {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                } else if isDeleting || backup.completed == nil {
                    ProgressView()
                }
                
                Text(backup.name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                Spacer()
                
                if backup.isLocked {
                    Image(systemName: "lock")
                        .foregroundStyle(.orange)
                }
            }
            
            HStack {
                Text(
                    isDeleting
                    ? "Deleting…"
                    : backup.deletionStatus == .failed
                    ? "Deletion failed"
                    : timeSinceISO(backup.created)
                )
                .secondary()
                
                Spacer()
                
                Text(formatBytes(backup.bytes))
            }
            .footnote()
            .secondary()
        }
    }
}

#Preview {
    List {
        BackupCardContent(PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
