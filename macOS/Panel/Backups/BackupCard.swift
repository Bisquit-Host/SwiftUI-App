import ScrechKit
import Calagopus

struct BackupCard: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: CalagopusServerBackup
    
    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }
    
    var body: some View {
        let isDeleting = vm.isDeleting(backup)

        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(backup.name)
                    
                    if backup.isLocked {
                        Image(systemName: "lock")
                    }

                    if isDeleting {
                        ProgressView()
                            .controlSize(.small)
                    } else if backup.deletionStatus == .failed {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }

                Text(
                    isDeleting
                    ? "Deleting…"
                    : backup.deletionStatus == .failed
                    ? "Deletion failed"
                    : timeSinceISO(backup.created)
                )
                    .footnote()
                    .secondary()
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
        .frame(minWidth: 200, maxWidth: 800)
        .contextMenu {
            Button(
                backup.isLocked ? "Unlock" : "Lock",
                systemImage: backup.isLocked ? "lock.open" : "lock"
            ) {
                Task {
                    await vm.toggleBackupLock(backup.uuid)
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
}

#Preview {
    BackupCard(PreviewProp.backupAttributes)
        .darkSchemePreferred()
        .environment(BackupVM(""))
}
