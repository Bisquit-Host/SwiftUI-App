import ScrechKit
import PteroNet

struct BackupCard: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        HStack {
            if backup.completedAt != nil {
                Image(systemName: "doc.zipper")
                    .title2(.semibold)
            } else {
                ZStack {
                    ProgressView()
                    
                    Image(systemName: "doc.zipper")
                        .title2(.semibold)
                        .opacity(0)
                }
            }
            
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    if backup.isLocked {
                        Image(systemName: "lock")
                            .foregroundStyle(.orange)
                    }
                    
                    Text(backup.name)
                        .lineLimit(1)
#if os(iOS)
                        .minimumScaleFactor(0.75)
                        .scaledToFit()
#endif
                }
                .animation(.default, value: backup.isLocked)
                .headline()
                
                let timeDifference = Text(timeSinceISO(backup.createdAt))
                    .foregroundStyle(.primary)
                
                Text("Created: \(timeDifference)")
                    .footnote()
                    .secondary()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(formatBytes(backup.bytes))
                .secondary()
        }
    }
}

#Preview {
    List {
        BackupCard(sampleJSON(.backupAttributes))
    }
}
