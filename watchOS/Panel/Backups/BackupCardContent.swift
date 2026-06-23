import ScrechKit
import Calagopus

struct BackupCardContent: View {
    private let backup: CalagopusServerBackup
    
    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if backup.completed == nil {
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
                Text(timeSinceISO(backup.created))
                
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
}
