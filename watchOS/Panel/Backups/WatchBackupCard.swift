import ScrechKit
import PteroNet

struct WatchBackupCard: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        NavigationLink {
            WatchBackupDetails(backup)
                .environment(vm)
        } label: {
            WatchBackupCardContent(backup)
        }
    }
}

#Preview {
    List {
        WatchBackupCard(PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
