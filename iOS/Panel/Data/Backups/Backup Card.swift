import ScrechKit
import PteroNet

struct BackupCard: View {
    @Environment(DataTabVM.self) private var vm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        Button {
            
        } label: {
            HStack(spacing: 16) {
                if backup.completed_at != nil {
                    Image(systemName: "doc.zipper")
                        .title2(.semibold)
                } else {
                    ZStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Image(systemName: "doc.zipper")
                            .title2(.semibold)
                            .opacity(0)
                    }
                }
                
                VStack(alignment: .leading) {
                    HStack(spacing: 5) {
                        if backup.is_locked {
                            Image(systemName: "lock")
                                .foregroundStyle(.orange)
                        }
                        
                        Text(backup.name)
                            .lineLimit(1)
#if os(iOS)
                            .minimumScaleFactor(0.5)
                            .scaledToFit()
#endif
                    }
                    .animation(.default, value: backup.is_locked)
                    .headline()
                    
                    let timeDifference = Text(timeSinceISO(backup.created_at))
                        .foregroundStyle(.primary)
                    
                    Text("Created: \(timeDifference)")
                        .footnote()
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    let size = Text(formatBytes(backup.bytes))
                        .foregroundStyle(.primary)
                    
                    Text("Size: \(size)")
                        .footnote()
                        .foregroundStyle(.secondary)
                }
#if os(tvOS)
                Spacer()
#endif
            }
            .foregroundStyle(.foreground)
        }
#if !os(tvOS)
        .swipeActions {
            Button(role: .destructive) {
                vm.deleteData(backup.uuid, endpoint: .backups)
            } label: {
                Image(systemName: "trash")
            }
            
            Button {
                vm.lockBackup(backup.uuid)
            } label: {
                Image(systemName: backup.is_locked ? "lock.open" : "lock")
                    .tint(backup.is_locked ? .orange : .green)
            }
        }
#endif
        .contextMenu {
            BackupContextMenu(backup)
                .environment(vm)
        }
    }
}

#Preview {
    List {
        BackupCard(
            sampleJSON(.backupAttributes)
        )
    }
}
