import ScrechKit
import PteroNet

struct BackupCardContent: View {
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if backup.completedAt == nil {
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
                Text(timeSinceISO(backup.createdAt))
                
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
