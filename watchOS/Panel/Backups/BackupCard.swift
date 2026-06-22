import ScrechKit
import Calagopus

struct BackupCard: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: CalagopusServerBackup
    
    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }
    
    var body: some View {
        NavigationLink {
            BackupDetails(backup)
                .environment(vm)
        } label: {
            BackupCardContent(backup)
        }
    }
}

#Preview {
    List {
        BackupCard(PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
