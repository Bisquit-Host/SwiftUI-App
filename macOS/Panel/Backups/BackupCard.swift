import ScrechKit
import Calagopus

struct BackupCard: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: CalagopusServerBackup
    
    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(backup.name)
                    
                    if backup.isLocked {
                        Image(systemName: "lock")
                    }
                }
                
                Text(timeSinceISO(backup.created))
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
            
            Button("Delete", systemImage: "trash", role: .destructive) {
                Task {
                    await vm.deleteBackup(backup.uuid)
                }
            }
            .disabled(backup.isLocked)
        }
    }
}

#Preview {
    BackupCard(PreviewProp.backupAttributes)
        .darkSchemePreferred()
        .environment(BackupVM(""))
}
