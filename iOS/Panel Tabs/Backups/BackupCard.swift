import ScrechKit
import Calagopus

struct BackupCard: View {
    @Environment(BackupVM.self) private var vm
    @State private var cardVM: BackupCardVM
    
    private let backup: CalagopusServerBackup
    
    init(_ id: String, _ backup: CalagopusServerBackup) {
        self.backup = backup
        self.cardVM = BackupCardVM(id)
    }
    
    var body: some View {
        let isDeleting = vm.isDeleting(backup)

        Button {
            
        } label: {
            HStack {
                if backup.deletionStatus == .failed {
                    Image(systemName: "exclamationmark.triangle")
                        .title2(.semibold)
                        .foregroundStyle(.red)
                } else if backup.completed != nil, !isDeleting {
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

                        if isDeleting {
                            Text("Deleting…")
                        } else if backup.deletionStatus == .failed {
                            Text("Deletion failed")
                                .foregroundStyle(.red)
                        } else {
                            Text(timeSinceISO(backup.created))
                                .secondary()
                        }
                    }
                    .footnote()
                    .animation(.default, value: backup.isLocked)
                }

                Spacer()

                Text(formatBytes(backup.bytes))
                    .footnote()
                    .secondary()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
            }
            .foregroundStyle(.foreground)
        }
        .safariCover($cardVM.showSafari, url: cardVM.url)
        .swipeActions {
            Button(role: .destructive, action: delete) {
                Image(systemName: "trash")
            }
            .disabled(isDeleting || backup.isLocked)
            
            Button(action: toggleLock) {
                Image(systemName: backup.isLocked ? "lock.open" : "lock")
                    .tint(backup.isLocked ? .orange : .green)
            }
            .disabled(isDeleting)
        }
        .contextMenu {
            BackupContextMenu(backup)
                .environment(vm)
                .environment(cardVM)
        }
    }
    
    private func delete() {
        guard !vm.isDeleting(backup), !backup.isLocked else {
            return
        }

        Task {
            await vm.deleteBackup(backup.uuid)
        }
    }
    
    private func toggleLock() {
        guard !vm.isDeleting(backup) else {
            return
        }

        Task {
            await vm.toggleBackupLock(backup.uuid)
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
