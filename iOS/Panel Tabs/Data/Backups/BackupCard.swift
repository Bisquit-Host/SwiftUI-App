import ScrechKit
import PteroNet

struct BackupCard: View {
    @Environment(BackupVM.self) private var vm
    @State private var cardVM: BackupCardVM
    
    private let backup: BackupAttributes
    
    init(_ id: String, _ backup: BackupAttributes) {
        self.backup = backup
        self.cardVM = BackupCardVM(id)
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
                    Text(backup.name)
                        .headline()
                        .lineLimit(1)
#if os(iOS)
                        .minimumScaleFactor(0.75)
                        .scaledToFit()
#endif
                    HStack(spacing: 4) {
                        if backup.isLocked {
                            Image(systemName: "lock")
                                .foregroundStyle(.orange)
                        }
                        
                        Text(timeSinceISO(backup.createdAt))
                            .secondary()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                    .footnote()
                    .animation(.default, value: backup.isLocked)
                }
                
                Spacer()
                
                Text(formatBytes(backup.bytes))
                    .footnote()
                    .secondary()
            }
            .foregroundStyle(.foreground)
        }
#if os(tvOS)
        .sheet($cardVM.showSafari) {
            QRCodeView(cardVM.url)
        }
#else
        .safariCover($cardVM.showSafari, url: cardVM.url)
        .swipeActions {
            Button(role: .destructive) {
                Task {
                    await vm.deleteBackup(backup.uuid)
                }
            } label: {
                Image(systemName: "trash")
            }
            
            Button {
                Task {
                    await vm.toggleBackupLock(backup.uuid)
                }
            } label: {
                Image(systemName: backup.isLocked ? "lock.open" : "lock")
                    .tint(backup.isLocked ? .orange : .green)
            }
        }
#endif
        .contextMenu {
            BackupContextMenu(backup)
                .environment(vm)
                .environment(cardVM)
        }
    }
}

#Preview {
    List {
        BackupCard("", PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
