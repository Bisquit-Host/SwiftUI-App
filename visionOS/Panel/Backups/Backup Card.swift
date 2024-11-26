import ScrechKit
import PteroNet

struct BackupCard: View {
    @Environment(BackupVM.self) private var vm
    @State private var cardVm: BackupCardVM
    
    private let backup: BackupAttributes
    
    init(_ id: String, _ backup: BackupAttributes) {
        self.backup = backup
        self.cardVm = BackupCardVM(id)
    }
    
    var body: some View {
        Button {
            
        } label: {
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
        .safariCover($cardVm.showSafari, url: cardVm.url)
        .swipeActions {
            Button(role: .destructive) {
                vm.deleteBackup(backup.uuid)
            } label: {
                Image(systemName: "trash")
            }
            
            Button {
                vm.lockBackup(backup.uuid)
            } label: {
                Image(systemName: backup.isLocked ? "lock.open" : "lock")
                    .tint(backup.isLocked ? .orange : .green)
            }
        }
        .contextMenu {
            BackupContextMenu(backup)
                .environment(vm)
                .environment(cardVm)
        }
    }
}

#Preview {
    List {
        BackupCard("", sampleJSON(.backupAttributes))
    }
}
