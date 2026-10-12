import ScrechKit
import Calagopus

struct BackupDetailsBrowseSection: View {
    @Environment(BackupVM.self) private var vm

    private let id: String
    private let backup: CalagopusServerBackup

    init(_ id: String, _ backup: CalagopusServerBackup) {
        self.id = id
        self.backup = backup
    }

    var body: some View {
        if vm.isBrowsable(backup) {
            Section {
                NavigationLink {
                    FolderFile(id, path: "/.backups/\(backup.uuid)/")
                } label: {
                    Label("Browse files", systemImage: "folder")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            BackupDetailsBrowseSection("", PreviewProp.backupAttributes)
        }
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
