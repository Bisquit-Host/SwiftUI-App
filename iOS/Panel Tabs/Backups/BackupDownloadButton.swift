import ScrechKit
import Calagopus

struct BackupDownloadButton: View {
    @Environment(BackupCardVM.self) private var cardVM
    
    private let backup: CalagopusServerBackup
    
    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }
    
    var body: some View {
        if backup.kind == .server && backup.isStreaming {
            Menu("Download", systemImage: "square.and.arrow.down") {
                ForEach(CalagopusFileArchiveFormat.streamable, id: \.self) { format in
                    AsyncButton("Download as \(format.title)", systemImage: "doc.zipper") {
                        await cardVM.downloadBackup(backup.uuid, format: format)
                    }
                }
            }
        } else {
            AsyncButton("Download", systemImage: "square.and.arrow.down") {
                await cardVM.downloadBackup(backup.uuid)
            }
        }
    }
}

#Preview {
    Menu("Preview") {
        BackupDownloadButton(PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupCardVM(""))
}
