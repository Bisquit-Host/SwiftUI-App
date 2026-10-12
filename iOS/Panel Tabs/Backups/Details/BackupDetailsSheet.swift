import ScrechKit
import Calagopus

struct BackupDetailsSheet: View {
    @Environment(BackupVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @State private var cardVM: BackupCardVM

    private let initialBackup: CalagopusServerBackup
    private let isSystem: Bool

    init(_ id: String, _ backup: CalagopusServerBackup, isSystem: Bool = false) {
        self.initialBackup = backup
        self.isSystem = isSystem
        self.cardVM = BackupCardVM(id)
    }

    var body: some View {
        let backup = vm.backup(initialBackup.uuid) ?? initialBackup

        List {
            BackupDetailsHeader(backup)

            BackupDetailsInfoSection(backup, isSystem: isSystem)

            if !backup.ignoredFiles.isEmpty {
                Section("Ignored files") {
                    ForEach(backup.ignoredFiles, id: \.self) {
                        Text($0)
                            .monospaced()
                            .footnote()
                            .textSelection(.enabled)
                    }
                }
            }
        }
        .navigationTitle("Backup")
        .toolbarTitleDisplayMode(.inline)
        .safariCover($cardVM.showSafari, url: cardVM.url)
        .animation(.default, value: backup.isLocked)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .close) {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                BackupDetailsMenu(backup, isSystem: isSystem)
                    .environment(cardVM)
            }
        }
    }
}

#Preview {
    NavigationStack {
        BackupDetailsSheet("", PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
